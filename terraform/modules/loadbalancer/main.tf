/**
 * Load Balancer module main configuration
 * Manages URL map, proxy, and forwarding rules for traffic routing
 */

# Network Endpoint Group for Backlog Webhook
resource "google_compute_region_network_endpoint_group" "backlog_webhook_neg" {
  name   = "backlog-webhook-neg-${var.suffix}"
  region = var.region
  cloud_run {
    service = var.backlog_webhook_service_name
  }
}

# Backend Service for Backlog Webhook
resource "google_compute_backend_service" "backlog_webhook_backend_service" {
  name                  = "backlog-webhook-backend-service-${var.suffix}"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.backlog_webhook_neg.id
  }
}

# URL Map for routing traffic
resource "google_compute_url_map" "url_map" {
  name            = "url-map-${var.suffix}"
  default_service = var.backend_service_id

  host_rule {
    hosts        = [var.domain_name]
    path_matcher = "service-path-matcher"
  }

  path_matcher {
    name            = "service-path-matcher"
    default_service = var.backend_service_id
    path_rule {
      paths   = [var.webhook_path]
      service = google_compute_backend_service.backlog_webhook_backend_service.id
    }
  }
}

# HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name            = "https-proxy-${var.suffix}"
  certificate_map = var.certificate_map_id
  url_map         = google_compute_url_map.url_map.id
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                                                         = "forwarding-rule-${var.suffix}"
  external_managed_backend_bucket_migration_testing_percentage = 0
  ip_address                                                   = var.lb_ip_address
  ip_protocol                                                  = "TCP"
  network                                                      = ""
  network_tier                                                 = "PREMIUM"
  port_range                                                   = "443-443"
  subnetwork                                                   = ""
  source_ip_ranges                                             = []
  target                                                       = google_compute_target_https_proxy.https_proxy.id
  labels                                                       = {}
}
