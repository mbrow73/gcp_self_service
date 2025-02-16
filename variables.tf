variable "projects" {
  description = "Map of project configurations"
  type = map(object({
    project_id     = string
    region         = string
    firewall_rules = list(object({
      name               = string
      direction          = string    // "INGRESS" or "EGRESS"
      source_ranges      = list(string)
      destination_ranges = list(string)
      target_tags        = list(string)
      allowed = list(object({
        protocol = string
        ports    = list(string)
      }))
    }))
  }))
}
