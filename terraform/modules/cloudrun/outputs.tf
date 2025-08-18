/**
 * Cloud Run module outputs
 * Exposes Cloud Run service information for use by other modules
 */

output "backlog_webhook_service_name" {
  description = "The name of the backlog webhook Cloud Run service"
  value       = google_cloud_run_v2_service.backlog_webhook_cloudrun.name
}

output "backlog_webhook_service_url" {
  description = "The URL of the backlog webhook Cloud Run service"
  value       = google_cloud_run_v2_service.backlog_webhook_cloudrun.uri
}

output "backlog_webhook_service_id" {
  description = "The ID of the backlog webhook Cloud Run service"
  value       = google_cloud_run_v2_service.backlog_webhook_cloudrun.id
}

output "backlog_webhook_service_location" {
  description = "The location of the backlog webhook Cloud Run service"
  value       = google_cloud_run_v2_service.backlog_webhook_cloudrun.location
}
