/**
 * Load Balancer module outputs
 * Exposes load balancer resources for monitoring and reference
 */

output "url_map_id" {
  description = "The ID of the URL map"
  value       = google_compute_url_map.url_map.id
}

output "https_proxy_id" {
  description = "The ID of the HTTPS proxy"
  value       = google_compute_target_https_proxy.https_proxy.id
}

output "forwarding_rule_id" {
  description = "The ID of the forwarding rule"
  value       = google_compute_global_forwarding_rule.forwarding_rule.id
}

output "backlog_webhook_backend_service_id" {
  description = "The ID of the backlog webhook backend service"
  value       = google_compute_backend_service.backlog_webhook_backend_service.id
}
