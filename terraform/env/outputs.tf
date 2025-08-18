/**
 * Main environment outputs
 * Exposes important infrastructure information
 */

# Network Outputs
output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.network.vpc_network_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.network.subnet_name
}

output "lb_ip_address" {
  description = "The static IP address of the load balancer"
  value       = module.network.lb_ip_address
}

# Cloud Run Outputs
output "backlog_webhook_service_url" {
  description = "The URL of the backlog webhook Cloud Run service"
  value       = module.cloudrun.backlog_webhook_service_url
}

# Load Balancer Outputs
output "url_map_id" {
  description = "The ID of the URL map"
  value       = module.loadbalancer.url_map_id
}

# DNS Outputs
output "dns_zone_name" {
  description = "The name of the DNS managed zone"
  value       = module.network.dns_zone_name
}
