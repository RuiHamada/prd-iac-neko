#!/bin/bash

# Exit on any error
set -e

# Get current git commit hash
# COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_HASH="latest"
PROJECT_ID="prd-iac-neko"
IMAGE_NAME="backlog-webhook-cloudrun"

echo "Building Docker image for commit: $COMMIT_HASH (ARM environment)"

# Verify Google Cloud authentication
echo "Verifying Google Cloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "Error: No active Google Cloud authentication found"
    echo "Please run: gcloud auth login or ensure service account is properly authenticated"
    exit 1
fi

# Verify project access
echo "Current project: $(gcloud config get-value project)"
if [ "$(gcloud config get-value project)" != "$PROJECT_ID" ]; then
    echo "Warning: Current project doesn't match expected project ID"
    echo "Setting project to: $PROJECT_ID"
    gcloud config set project $PROJECT_ID
fi

# Ensure Docker is configured for GCR
echo "Configuring Docker for Google Container Registry..."
gcloud auth configure-docker gcr.io --quiet

# Build Docker image with linux/amd64 platform for Cloud Run compatibility
echo "Building and pushing Docker image..."
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
