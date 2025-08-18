/**
 * Load Balancer module variables
 * Contains all configurable parameters for load balancer setup
 */

variable "project_id" {
  description = "The GCP project ID where resources will be created"
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

variable "domain_name" {
  description = "The domain name for load balancer configuration"
  type        = string
}

variable "backend_service_id" {
  description = "The ID of the backend service"
  type        = string
}

variable "certificate_map_id" {
  description = "The ID of the certificate map"
  type        = string
}

variable "lb_ip_id" {
  description = "The ID of the static IP address for the load balancer"
  type        = string
}

variable "backlog_webhook_service_name" {
  description = "The name of the backlog webhook Cloud Run service"
  type        = string
}

variable "webhook_path" {
  description = "Path for the webhook endpoint"
  type        = string
  default     = "/webhook/backlog/fm"
}
