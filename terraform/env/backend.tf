/**
 * Backend configuration for Terraform state
 * Stores state in Google Cloud Storage
 * Note: Backend configuration cannot use variables, so bucket name is hardcoded
 */

terraform {
  backend "gcs" {
    bucket = "prd-iac-neko-tfstate"
    prefix = "terraform/state"
  }
}