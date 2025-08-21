#!/usr/bin/env python3
"""
Docker Local Test Script for Webhook Message Processing Logic
Tests the message extraction and formatting without external dependencies
"""

import json
import logging

def setup_logging():
    """Setup logging for test"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)

def load_sample_data():
    """Load sample webhook data"""
    with open('sample.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def test_comment_event_detection():
    """Test is_comment_event function"""
    logger = logging.getLogger(__name__)
    logger.info("Testing comment event detection...")
    
    try:
        # Import functions from main
        from main import is_comment_event
        
        sample_data = load_sample_data()
        
        result = is_comment_event(sample_data)
        logger.info(f"is_comment_event result: {result}")
        
        if result:
            logger.info("✅ Comment event detection PASSED")
            return True
        else:
            logger.error("❌ Comment event detection FAILED")
            return False
            
    except Exception as e:
        logger.error(f"❌ Comment event detection error: {e}")
        return False

def test_comment_data_extraction():
    """Test extract_comment_data function"""
    logger = logging.getLogger(__name__)
    logger.info("Testing comment data extraction...")
    
    try:
        from main import extract_comment_data
        
        sample_data = load_sample_data()
        
        extracted_data = extract_comment_data(sample_data)
        
        logger.info("✅ Comment data extraction successful")
        logger.info("Extracted data structure:")
        logger.info(json.dumps(extracted_data, indent=2, ensure_ascii=False))
        
        # Validate expected structure
        expected_comment_id = sample_data["content"]["comment"]["id"]
        actual_comment_id = extracted_data["content"]["comment"]["id"]
        
        if expected_comment_id == actual_comment_id:
            logger.info(f"✅ Comment ID matches: {actual_comment_id}")
        else:
            logger.error(f"❌ Comment ID mismatch: expected {expected_comment_id}, got {actual_comment_id}")
            return False
        
        # Check required fields for AI processor compatibility
        required_fields = [
            ("content", "comment", "id"),
            ("content", "comment", "content"),
            ("createdUser", "name"),
            ("project", "projectKey"),
            ("type")
        ]
        
        for field_path in required_fields:
            data = extracted_data
            for field in field_path:
                if field not in data:
                    logger.error(f"❌ Missing field: {'.'.join(field_path)}")
                    return False
                data = data[field]
        
        logger.info("✅ All required fields present")
        return True
        
    except Exception as e:
        logger.error(f"❌ Comment data extraction error: {e}")
        return False

def test_message_format_compatibility():
    """Test compatibility with AI processor expected format"""
    logger = logging.getLogger(__name__)
    logger.info("Testing AI processor format compatibility...")
    
    try:
        from main import extract_comment_data
        
        sample_data = load_sample_data()
        extracted_data = extract_comment_data(sample_data)
        
        # Simulate what AI processor does
        comment_id = extracted_data.get("content", {}).get("comment", {}).get("id")
        
        if comment_id:
            logger.info(f"✅ AI processor format compatibility PASSED")
            logger.info(f"   Comment ID accessible via content.comment.id: {comment_id}")
            return True
        else:
            logger.error("❌ AI processor format compatibility FAILED")
            logger.error("   Cannot access comment ID via content.comment.id")
            return False
            
    except Exception as e:
        logger.error(f"❌ Format compatibility test error: {e}")
        return False

def main():
    """Main test execution"""
    logger = setup_logging()
    logger.info("🧪 Starting Docker Local Tests for Webhook Message Processing")
    
    # Load sample data for info
    try:
        sample_data = load_sample_data()
        logger.info(f"Sample data loaded:")
        logger.info(f"  Event type: {sample_data.get('type')}")
        logger.info(f"  Comment ID: {sample_data.get('content', {}).get('comment', {}).get('id')}")
        logger.info(f"  Comment content: {sample_data.get('content', {}).get('comment', {}).get('content')}")
        logger.info(f"  User: {sample_data.get('createdUser', {}).get('name')}")
        logger.info(f"  Project: {sample_data.get('project', {}).get('projectKey')}")
    except Exception as e:
        logger.error(f"❌ Failed to load sample data: {e}")
        return False
    
    # Run tests
    tests = [
        ("Comment Event Detection", test_comment_event_detection),
        ("Comment Data Extraction", test_comment_data_extraction), 
        ("AI Processor Format Compatibility", test_message_format_compatibility)
    ]
    
    results = []
    for test_name, test_func in tests:
        logger.info(f"\n{'='*50}")
        logger.info(f"Running: {test_name}")
        logger.info(f"{'='*50}")
        
        result = test_func()
        results.append((test_name, result))
    
    # Summary
    logger.info(f"\n📊 Docker Local Test Results:")
    all_passed = True
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        logger.info(f"  {test_name}: {status}")
        if not result:
            all_passed = False
    
    logger.info(f"\n🎯 Overall Docker Local Tests: {'✅ ALL PASSED' if all_passed else '❌ SOME FAILED'}")
    
    return all_passed

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
