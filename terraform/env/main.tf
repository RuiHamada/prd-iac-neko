/**
 * Main Terraform configuration
 * Orchestrates all infrastructure modules for the application environment
 */

# Network Infrastructure Module
module "network" {
  source = "../modules/network"

  project_id          = var.project_id
  region              = var.region
  suffix              = var.suffix
  vpc_cidr            = var.vpc_cidr
  domain_name         = var.domain_name
  lb_ip_address       = var.lb_ip_address
  dns_zone_name       = var.dns_zone_name
  cert_project_number = var.cert_project_number
}

# Cloud Run Services Module
module "cloudrun" {
  source = "../modules/cloudrun"

  project_id                    = var.project_id
  region                        = var.region
  suffix                        = var.suffix
  backlog_webhook_image_tag     = var.backlog_webhook_image_tag
  backlog_webhook_secret_token  = var.backlog_webhook_secret_token
}

# Load Balancer Module
module "loadbalancer" {
  source = "../modules/loadbalancer"

  project_id                    = var.project_id
  region                        = var.region
  suffix                        = var.suffix
  domain_name                   = var.domain_name
  backend_service_id            = module.network.backend_service_id
  certificate_map_id            = module.network.certificate_map_id
  lb_ip_address                 = var.lb_ip_address
  backlog_webhook_service_name  = module.cloudrun.backlog_webhook_service_name
  webhook_path                  = var.webhook_path

  depends_on = [
    module.network,
    module.cloudrun
  ]
}
