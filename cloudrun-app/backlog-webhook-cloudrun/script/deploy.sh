gcloud run deploy backlog-webhook-cloudrun-neko \
  --image gcr.io/prd-iac-neko/backlog-webhook-cloudrun:latest \
  --platform managed \
  --region asia-northeast1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --project=prd-iac-neko
