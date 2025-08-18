/**
 * Cloud Run module variables
 * Contains all configurable parameters for Cloud Run services
 */

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region where Cloud Run services will be deployed"
  type        = string
  default     = "asia-northeast1"
}

variable "suffix" {
  description = "A suffix to append to resource names for environment differentiation"
  type        = string
}

variable "backlog_webhook_image_tag" {
  description = "The image tag for the backlog-webhook-cloudrun service"
  type        = string
}

variable "backlog_webhook_secret_token" {
  description = "The secret token for authenticating Backlog Webhook requests"
  type        = string
  sensitive   = true
}

variable "ingress_traffic" {
  description = "Ingress traffic setting for Cloud Run service"
  type        = string
  default     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

variable "labels" {
  description = "Labels to apply to Cloud Run resources"
  type        = map(string)
  default = {
    goog-terraform-provisioned = "true"
  }
}
