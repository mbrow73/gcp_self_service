variable "project_id" {
  type        = string
  description = "GCP project ID for this configuration."
}

variable "region" {
  type        = string
  description = "GCP region."
  default     = "us-central1"
}

variable "firewall_rules" {
  description = "List of firewall rule definitions for this project."
  type = list(object({
    name                = string
    direction           = string                    # "INGRESS" or "EGRESS"
    source_ranges       = list(string)              # For INGRESS rules; leave empty for EGRESS.
    destination_ranges  = list(string)              # For EGRESS rules; leave empty for INGRESS.
    target_tags         = list(string)
    allowed = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}
