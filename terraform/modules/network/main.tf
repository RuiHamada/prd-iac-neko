/**
 * Network module main configuration
 * Manages VPC, subnets, NAT, load balancer, DNS, and security components
 */

# VPC Network
resource "google_compute_network" "vpc_network" {
  auto_create_subnetworks      = false
  bgp_always_compare_med       = false
  bgp_best_path_selection_mode = "LEGACY"
  enable_ula_internal_ipv6     = false
  mtu                          = 0
  name                         = "vpc-${var.suffix}"
  routing_mode                 = "REGIONAL"
}

# Subnet
resource "google_compute_subnetwork" "subnet_01" {
  ip_cidr_range              = var.vpc_cidr
  name                       = "subnet-${var.suffix}"
  network                    = google_compute_network.vpc_network.id
  private_ip_google_access   = true
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  purpose                    = "PRIVATE"
  region                     = var.region
  stack_type                 = "IPV4_ONLY"
}

# Cloud Router for NAT
resource "google_compute_router" "cloud_router" {
  name                          = "router-${var.suffix}"
  encrypted_interconnect_router = false
  network                       = google_compute_network.vpc_network.id
  region                        = var.region
}

# Static IP for NAT
resource "google_compute_address" "nat_ip" {
  name   = "nat-ip-${var.suffix}"
  region = var.region
}

# Cloud NAT
resource "google_compute_router_nat" "cloud_nat" {
  name                               = "nat-gateway-${var.suffix}"
  router                             = google_compute_router.cloud_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ips                           = [google_compute_address.nat_ip.id]
}

# Global static IP for load balancer
resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip-${var.suffix}"
}

# Cloud Armor security policy
resource "google_compute_security_policy" "armor_policy" {
  name        = "armor-policy-${var.suffix}"
  description = var.security_policy_description
}

# Cloud Armor rule - Allow Japan only
resource "google_compute_security_policy_rule" "armor_rule" {
  security_policy = google_compute_security_policy.armor_policy.name
  action          = "allow"
  priority        = 1000
  preview         = false
  match {
    expr {
      expression = "origin.region_code == 'JP'"
    }
  }
}

# SSL Certificate
resource "google_certificate_manager_certificate" "ssl_cert" {
  labels = {}
  name   = "ssl-cert-${var.suffix}"
  managed {
    dns_authorizations = []
    domains = [
      var.domain_name,
    ]
  }
}

# Certificate Map
resource "google_certificate_manager_certificate_map" "cert_map" {
  name = "cert-map-${var.suffix}"
}

# Certificate Map Entry
resource "google_certificate_manager_certificate_map_entry" "cert_map_entry" {
  name = "cert-map-entry-${var.suffix}"
  certificates = [
    "projects/${var.cert_project_number}/locations/global/certificates/ssl-cert-${var.suffix}",
  ]
  hostname = var.domain_name
  labels   = {}
  map      = google_certificate_manager_certificate_map.cert_map.name
}

# Backend Service for secure app (placeholder)
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name   = "neg-${var.suffix}"
  region = var.region
  cloud_run {
    service = "secure-app-${var.suffix}"
  }
}

# Backend Service
resource "google_compute_backend_service" "backend_service" {
  connection_draining_timeout_sec = 0
  name                            = "backend-service-${var.suffix}"
  security_policy                 = google_compute_security_policy.armor_policy.id
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# DNS Managed Zone
resource "google_dns_managed_zone" "managed_zone" {
  description = "DNS zone for domain: ${var.domain_name}"
  dns_name    = "${var.domain_name}."
  labels      = {}
  name        = var.dns_zone_name

  cloud_logging_config {
    enable_logging = false
  }

  dnssec_config {
    kind          = "dns#managedZoneDnsSecConfig"
    non_existence = "nsec3"
    state         = "on"

    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
      kind       = "dns#dnsKeySpec"
    }
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 1024
      key_type   = "zoneSigning"
      kind       = "dns#dnsKeySpec"
    }
  }
}

# DNS A Record
resource "google_dns_record_set" "a_record" {
  name         = "${var.domain_name}."
  managed_zone = google_dns_managed_zone.managed_zone.name
  rrdatas      = [var.lb_ip_address]
  ttl          = 300
  type         = "A"
}
