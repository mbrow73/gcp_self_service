variable "GOOGLE_CREDENTIALS" {
    description = "The credentials to authenticate with GCP"
    type        = string
    }

variable "project" {
    description = "The project ID to deploy firewall rules"
    type        = string
    }

variable "region" {
    description = "The region to deploy firewall rules"
    type        = string
    default     = "us-central1"
    }


  