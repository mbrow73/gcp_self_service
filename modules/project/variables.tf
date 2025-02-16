variable "project_id" {
  type        = string
  description = "GCP project ID for this project."
}

variable "region" {
  type        = string
  description = "GCP region for this project."
}

variable "network" {
  type        = string
  description = "Network to use for the project."
  default     = "default"
}

variable "firewall_rules" {
  description = "List of firewall rule definitions for this project."
  type = list(object({
    name               = string
    direction          = string
    source_ranges      = list(string)
    destination_ranges = list(string)
    target_tags        = list(string)
    allowed = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}
