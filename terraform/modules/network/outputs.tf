/**
 * Network module outputs
 * Exposes network resources for use by other modules
 */

output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet_01.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet_01.name
}

output "backend_service_id" {
  description = "The ID of the backend service"
  value       = google_compute_backend_service.backend_service.id
}

output "certificate_map_id" {
  description = "The ID of the certificate map"
  value       = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.cert_map.id}"
}

output "lb_ip_address" {
  description = "The static IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "lb_ip_id" {
  description = "The ID of the static IP address for the load balancer"
  value       = google_compute_global_address.lb_ip.id
}

output "dns_zone_name" {
  description = "The name of the DNS managed zone"
  value       = google_dns_managed_zone.managed_zone.name
}

output "security_policy_id" {
  description = "The ID of the Cloud Armor security policy"
  value       = google_compute_security_policy.armor_policy.id
}
