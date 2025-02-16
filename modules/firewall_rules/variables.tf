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
