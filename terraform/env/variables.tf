/**
 * Main environment variables
 * Central configuration for all infrastructure components
 */

# Core Infrastructure Variables
variable "project_id" {
  description = "The GCP project ID where all resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region where regional resources will be created"
  type        = string
  default     = "asia-northeast1"
}

variable "suffix" {
  description = "A suffix to append to resource names for environment differentiation"
  type        = string
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "domain_name" {
  description = "The domain name for DNS and certificate resources"
  type        = string
}

variable "lb_ip_address" {
  description = "Static IP address for the load balancer"
  type        = string
}

variable "dns_zone_name" {
  description = "Name for the DNS managed zone"
  type        = string
  default     = "g-app-com"
}

variable "cert_project_number" {
  description = "GCP project number for certificate references"
  type        = string
}

# Cloud Run Configuration
variable "backlog_webhook_image_tag" {
  description = "The image tag for the backlog-webhook-cloudrun service"
  type        = string
}

variable "backlog_webhook_secret_token" {
  description = "The secret token for authenticating Backlog Webhook requests"
  type        = string
  sensitive   = true
}

# Load Balancer Configuration
variable "webhook_path" {
  description = "Path for the webhook endpoint"
  type        = string
  default     = "/webhook/backlog/fm"
}