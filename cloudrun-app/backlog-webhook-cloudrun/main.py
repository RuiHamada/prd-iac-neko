import os
import hmac
import json
from flask import Flask, request, jsonify
import logging
from google.cloud import pubsub_v1
from google.cloud import secretmanager

app = Flask(__name__)

# Enhanced logging configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Application startup logging
logging.info("Flask application starting...")
logging.info(f"PORT environment variable: {os.environ.get('PORT', 'Not set')}")

# Configuration
PROJECT_ID = os.environ.get("PROJECT_ID")
PUBSUB_TOPIC = os.environ.get("PUBSUB_TOPIC", "backlog-webhook-processor")

# Initialize Pub/Sub client
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, PUBSUB_TOPIC)

# Initialize Secret Manager client
secret_client = secretmanager.SecretManagerServiceClient()

def get_secret(secret_name: str) -> str:
    """Retrieve secret value from Secret Manager.
    
    Args:
        secret_name: Name of the secret to retrieve
        
    Returns:
        str: The secret value
        
    Raises:
        Exception: If secret retrieval fails
    """
    try:
        secret_path = f"projects/{PROJECT_ID}/secrets/{secret_name}/versions/latest"
        response = secret_client.access_secret_version(request={"name": secret_path})
        return response.payload.data.decode("UTF-8")
    except Exception as e:
        logging.error(f"Failed to retrieve secret {secret_name}: {e}")
        raise

def publish_message(payload: dict) -> str:
    """Publish message to Pub/Sub topic.
    
    Args:
        payload: The message payload to publish
        
    Returns:
        str: The message ID
        
    Raises:
        Exception: If message publishing fails
    """
    try:
        message_data = json.dumps(payload).encode("utf-8")
        future = publisher.publish(topic_path, message_data)
        message_id = future.result()
        logging.info(f"Published message to {PUBSUB_TOPIC}: {message_id}")
        return message_id
    except Exception as e:
        logging.error(f"Failed to publish message to Pub/Sub: {e}")
        raise

def is_comment_event(payload: dict) -> bool:
    """Check if the webhook payload is a comment event.
    
    Args:
        payload: The webhook payload
        
    Returns:
        bool: True if it's a comment event, False otherwise
    """
    try:
        event_type = payload.get("type", 0)
        content = payload.get("content", {})
        comment = content.get("comment")
        
        # Event type 3 = Comment added, type 4 = Comment updated
        if event_type in [3, 4] and comment:
            logging.info(f"Comment event detected: type={event_type}, comment_id={comment.get('id')}")
            return True
        
        logging.info(f"Non-comment event ignored: type={event_type}")
        return False
    except Exception as e:
        logging.error(f"Error checking comment event: {e}")
        return False

def extract_comment_data(payload: dict) -> dict:
    """Extract relevant comment data from webhook payload.
    Format the data to match the existing AI processor's expected structure.
    
    Args:
        payload: The webhook payload
        
    Returns:
        dict: Extracted comment data in AI processor compatible format
    """
    try:
        # Preserve the original webhook structure for AI processor compatibility
        content = payload.get("content", {})
        comment = content.get("comment", {})
        project = payload.get("project", {})
        created_user = payload.get("createdUser", {})
        
        # Extract issue information if available
        issue = content.get("issue", {})
        
        # Format data to match existing AI processor expectations
        comment_data = {
            "content": {
                "comment": {
                    "id": comment.get("id"),
                    "content": comment.get("content", ""),
                    "created": comment.get("created"),
                    "updated": comment.get("updated"),
                    "createdUser": created_user
                },
                "issue": {
                    "id": issue.get("id"),
                    "issueKey": issue.get("issueKey"),
                    "summary": issue.get("summary")
                } if issue else None
            },
            "project": {
                "id": project.get("id"),
                "projectKey": project.get("projectKey"),
                "name": project.get("name")
            },
            "createdUser": created_user,
            "type": payload.get("type"),
            "created": payload.get("created")
        }
        
        logging.info(f"Extracted comment data: comment_id={comment_data['content']['comment']['id']}, "
                    f"user={comment_data['createdUser']['name']}")
        
        return comment_data
    except Exception as e:
        logging.error(f"Error extracting comment data: {e}")
        raise

@app.route("/")
def health_check():
    """Health check endpoint for Cloud Run."""
    logging.info("Health check endpoint accessed successfully")
    return "OK", 200

@app.route("/webhook/backlog/fm", methods=["POST"])
def handle_backlog_webhook():
    """Receives and validates a webhook from Backlog, then publishes to Pub/Sub for processing."""
    try:
        # Get secret token from environment or Secret Manager
        secret_token = os.environ.get("BACKLOG_WEBHOOK_SECRET_TOKEN")
        if not secret_token:
            try:
                secret_token = get_secret("backlog-webhook-secret-token")
            except Exception as e:
                logging.error(f"Failed to retrieve webhook secret: {e}")
                return jsonify(error="Internal Server Error"), 500
        
        query_token = request.args.get("token", "")

        # Validate webhook token
        if not secret_token or not hmac.compare_digest(query_token, secret_token):
            logging.warning("Forbidden: Invalid or missing token provided.")
            return jsonify(error="Forbidden"), 403

        # Validate content type
        if not request.is_json:
            logging.error("Bad Request: Content-Type is not application/json.")
            return jsonify(error="Bad Request"), 400

        # Parse JSON payload
        try:
            payload = request.get_json()
        except Exception as e:
            logging.error(f"Bad Request: Failed to parse JSON payload. Error: {e}")
            return jsonify(error="Bad Request"), 400

        logging.info(f"Received Backlog webhook payload: event_type={payload.get('type')}")
        
        # Check if this is a comment event
        if not is_comment_event(payload):
            logging.info("Webhook event is not a comment event, ignoring.")
            return jsonify(success=True, message="Event ignored - not a comment"), 200

        # Extract and structure comment data
        try:
            comment_data = extract_comment_data(payload)
        except Exception as e:
            logging.error(f"Failed to extract comment data: {e}")
            return jsonify(error="Internal Server Error"), 500

        # Publish to Pub/Sub for async processing
        try:
            message_id = publish_message(comment_data)
            logging.info(f"Successfully published comment to Pub/Sub: message_id={message_id}, "
                        f"comment_id={comment_data['content']['comment']['id']}")
            
            return jsonify({
                "success": True,
                "message": "Comment published for processing",
                "message_id": message_id,
                "comment_id": comment_data['content']['comment']['id']
            }), 200
            
        except Exception as e:
            logging.error(f"Failed to publish message to Pub/Sub: {e}")
            return jsonify(error="Internal Server Error"), 500

    except Exception as e:
        logging.error(f"Unexpected error in webhook handler: {e}")
        return jsonify(error="Internal Server Error"), 500

if __name__ == "__main__":
    # This block is for local development.
    # In Cloud Run, Gunicorn will be used as the server.
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=False)
