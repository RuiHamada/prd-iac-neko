#!/usr/bin/env python3
"""
End-to-End Test Script for Backlog Webhook → Pub/Sub → AI Processing Flow
Tests the complete flow using sample.json data
"""

import json
import os
import requests
import time
from google.cloud import pubsub_v1
from google.cloud import logging as cloud_logging

def setup_logging():
    """Setup logging for test execution"""
    import logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)

def load_sample_data():
    """Load sample webhook data from sample.json"""
    with open('sample.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def test_webhook_endpoint(webhook_url: str, token: str, sample_data: dict, logger):
    """Test the webhook endpoint with sample data"""
    logger.info("Testing webhook endpoint...")
    
    try:
        headers = {
            'Content-Type': 'application/json'
        }
        
        # Add token as query parameter
        url_with_token = f"{webhook_url}?token={token}"
        
        response = requests.post(
            url_with_token,
            json=sample_data,
            headers=headers,
            timeout=30
        )
        
        logger.info(f"Webhook response status: {response.status_code}")
        logger.info(f"Webhook response body: {response.text}")
        
        if response.status_code == 200:
            response_data = response.json()
            message_id = response_data.get('message_id')
            comment_id = response_data.get('comment_id')
            
            logger.info(f"✅ Webhook test passed!")
            logger.info(f"   Message ID: {message_id}")
            logger.info(f"   Comment ID: {comment_id}")
            
            return True, message_id, comment_id
        else:
            logger.error(f"❌ Webhook test failed: {response.status_code} - {response.text}")
            return False, None, None
            
    except Exception as e:
        logger.error(f"❌ Webhook test exception: {e}")
        return False, None, None

def check_pubsub_message(project_id: str, subscription_name: str, expected_comment_id: str, logger):
    """Check if message was published to Pub/Sub"""
    logger.info("Checking Pub/Sub message...")
    
    try:
        subscriber = pubsub_v1.SubscriberClient()
        subscription_path = subscriber.subscription_path(project_id, subscription_name)
        
        # Pull messages with short timeout
        response = subscriber.pull(
            request={
                "subscription": subscription_path,
                "max_messages": 10,
                "timeout": 5.0
            }
        )
        
        for received_message in response.received_messages:
            try:
                message_data = json.loads(received_message.message.data.decode('utf-8'))
                comment_id = message_data.get("content", {}).get("comment", {}).get("id")
                
                if str(comment_id) == str(expected_comment_id):
                    logger.info(f"✅ Found matching message in Pub/Sub!")
                    logger.info(f"   Comment ID: {comment_id}")
                    logger.info(f"   Message timestamp: {received_message.message.publish_time}")
                    
                    # Acknowledge the message
                    subscriber.acknowledge(
                        request={
                            "subscription": subscription_path,
                            "ack_ids": [received_message.ack_id]
                        }
                    )
                    return True
                    
            except Exception as e:
                logger.warning(f"Error parsing message: {e}")
                continue
        
        logger.warning("❌ No matching message found in Pub/Sub")
        return False
        
    except Exception as e:
        logger.error(f"❌ Pub/Sub check failed: {e}")
        return False

def check_ai_processor_logs(project_id: str, comment_id: str, logger):
    """Check Cloud Logging for AI processor activity"""
    logger.info("Checking AI processor logs...")
    
    try:
        client = cloud_logging.Client(project=project_id)
        
        # Query for recent logs from AI processor
        filter_str = f'''
        resource.type="cloud_run_revision"
        resource.labels.service_name="backlog-ai-processor"
        timestamp >= "{time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(time.time() - 300))}"
        jsonPayload.comment_id="{comment_id}"
        '''
        
        entries = list(client.list_entries(filter_=filter_str, max_results=10))
        
        if entries:
            logger.info(f"✅ Found {len(entries)} AI processor log entries")
            for entry in entries[:3]:  # Show first 3 entries
                logger.info(f"   Log: {entry.payload}")
            return True
        else:
            logger.warning("❌ No AI processor logs found")
            return False
            
    except Exception as e:
        logger.error(f"❌ Log check failed: {e}")
        return False

def main():
    """Main test execution"""
    logger = setup_logging()
    logger.info("🚀 Starting E2E Test for Backlog Webhook System")
    
    # Configuration
    webhook_url = os.environ.get('WEBHOOK_URL', 'http://localhost:8080/webhook/backlog/fm')
    webhook_token = os.environ.get('BACKLOG_WEBHOOK_SECRET_TOKEN', 'test-token')
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    subscription_name = os.environ.get('PUBSUB_SUBSCRIPTION', 'backlog-webhook-processor-sub')
    
    if not project_id:
        logger.error("❌ GOOGLE_CLOUD_PROJECT environment variable not set")
        return False
    
    logger.info(f"Configuration:")
    logger.info(f"  Webhook URL: {webhook_url}")
    logger.info(f"  Project ID: {project_id}")
    logger.info(f"  Subscription: {subscription_name}")
    
    # Load sample data
    try:
        sample_data = load_sample_data()
        expected_comment_id = sample_data["content"]["comment"]["id"]
        logger.info(f"  Expected Comment ID: {expected_comment_id}")
    except Exception as e:
        logger.error(f"❌ Failed to load sample data: {e}")
        return False
    
    # Test 1: Webhook endpoint
    webhook_success, message_id, comment_id = test_webhook_endpoint(
        webhook_url, webhook_token, sample_data, logger
    )
    if not webhook_success:
        logger.error("❌ E2E Test failed at webhook stage")
        return False
    
    # Wait for message propagation
    logger.info("⏳ Waiting for message propagation...")
    time.sleep(10)
    
    # Test 2: Pub/Sub message
    pubsub_success = check_pubsub_message(
        project_id, subscription_name, expected_comment_id, logger
    )
    
    # Test 3: AI processor logs (optional, may take time)
    logger.info("⏳ Waiting for AI processor...")
    time.sleep(20)
    
    ai_processor_success = check_ai_processor_logs(
        project_id, expected_comment_id, logger
    )
    
    # Summary
    logger.info("\n📊 E2E Test Results:")
    logger.info(f"  Webhook Endpoint: {'✅ PASS' if webhook_success else '❌ FAIL'}")
    logger.info(f"  Pub/Sub Message:  {'✅ PASS' if pubsub_success else '❌ FAIL'}")
    logger.info(f"  AI Processor:     {'✅ PASS' if ai_processor_success else '❌ FAIL'}")
    
    overall_success = webhook_success and pubsub_success
    logger.info(f"\n🎯 Overall E2E Test: {'✅ PASS' if overall_success else '❌ FAIL'}")
    
    return overall_success

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
