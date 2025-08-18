import os
import hmac
from flask import Flask, request, jsonify
import logging

app = Flask(__name__)

# Enhanced logging configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Application startup logging
logging.info("Flask application starting...")
logging.info(f"PORT environment variable: {os.environ.get('PORT', 'Not set')}")

@app.route("/")
def health_check():
    """Health check endpoint for Cloud Run."""
    logging.info("Health check endpoint accessed successfully")
    return "OK", 200

@app.route("/webhook/backlog/fm", methods=["POST"])
def handle_backlog_webhook():
    """Receives and validates a webhook from Backlog."""
    secret_token = os.environ.get("BACKLOG_WEBHOOK_SECRET_TOKEN")
    query_token = request.args.get("token", "")

    if not secret_token or not hmac.compare_digest(query_token, secret_token):
        logging.warning("Forbidden: Invalid or missing token provided.")
        return jsonify(error="Forbidden"), 403

    if not request.is_json:
        logging.error("Bad Request: Content-Type is not application/json.")
        return jsonify(error="Bad Request"), 400

    try:
        payload = request.get_json()
    except Exception as e:
        logging.error(f"Bad Request: Failed to parse JSON payload. Error: {e}")
        return jsonify(error="Bad Request"), 400

    logging.info(f"Received Backlog webhook payload: {payload}")
    return jsonify(success=True), 200

if __name__ == "__main__":
    # This block is for local development.
    # In Cloud Run, Gunicorn will be used as the server.
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=False)
