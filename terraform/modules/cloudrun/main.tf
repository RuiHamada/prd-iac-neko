/**
 * Cloud Run module main configuration
 * Manages the backlog webhook Cloud Run service and related resources
 */

# Backlog Webhook Cloud Run Service
resource "google_cloud_run_v2_service" "backlog_webhook_cloudrun" {
  name     = "backlog-webhook-cloudrun-${var.suffix}"
  location = var.region
  ingress  = var.ingress_traffic
  
  # Disable deletion protection to allow Terraform to manage lifecycle
  deletion_protection = false

  template {
    containers {
      image = "gcr.io/${var.project_id}/backlog-webhook-cloudrun:${var.backlog_webhook_image_tag}"
      
      env {
        name  = "BACKLOG_WEBHOOK_SECRET_TOKEN"
        value = var.backlog_webhook_secret_token
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "PUBSUB_TOPIC"
        value = "backlog-webhook-processor"
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
    }
  }

  labels = var.labels
}

# IAM binding to allow public access to the webhook
resource "google_cloud_run_v2_service_iam_member" "backlog_webhook_cloudrun_invoker" {
  name     = google_cloud_run_v2_service.backlog_webhook_cloudrun.name
  location = google_cloud_run_v2_service.backlog_webhook_cloudrun.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
