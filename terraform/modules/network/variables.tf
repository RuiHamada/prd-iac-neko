/**
 * Network module variables
 * Contains all configurable parameters for network infrastructure
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
  default     = "narerukun-com"
}

variable "security_policy_description" {
  description = "Description for the Cloud Armor security policy"
  type        = string
  default     = "Allow Japan Only"
}

variable "cert_project_number" {
  description = "GCP project number for certificate references"
  type        = string
}
