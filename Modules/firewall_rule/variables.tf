variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "network" {
  type        = string
  description = "The network where the firewall rules will be applied."
}

variable "firewall_rules" {
  description = "List of firewall rule definitions."
  type = list(object({
    name                = string
    direction           = string                    # "INGRESS" or "EGRESS"
    source_ranges       = list(string)              # Used for INGRESS rules
    destination_ranges  = list(string)              # Used for EGRESS rules
    target_tags         = list(string)
    allowed = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}
