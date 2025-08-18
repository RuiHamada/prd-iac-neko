#!/bin/bash

# Exit on any error
set -e

# Get current git commit hash
COMMIT_HASH=$(git rev-parse HEAD)
PROJECT_ID="prd-iac-neko"
IMAGE_NAME="backlog-webhook-cloudrun"

echo "Building Docker image for commit: $COMMIT_HASH (ARM environment)"

# Build Docker image with linux/amd64 platform for Cloud Run compatibility
docker buildx build --platform linux/amd64 \
             -t gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${COMMIT_HASH} \
             -t gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest \
             --push .

echo "Successfully built and pushed:"
echo "  gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${COMMIT_HASH}"
echo "  gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest"
echo ""
echo "To use this image, update terraform.tfvars with:"
echo "  backlog_webhook_cloudrun_image_tag = \"${COMMIT_HASH}\""
