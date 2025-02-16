variable "ingress_rules" {
  type = list(object({
    rule_name      = string   # Format: "ingress-<purpose>"
    from_ranges    = list(string)
    to_ports       = list(number)
    target_tags    = list(string)
    priority       = number
  }))
}

resource "google_compute_firewall" "ingress" {
  for_each = { for rule in var.ingress_rules : rule.rule_name => rule }

  name        = each.value.rule_name
  direction   = "INGRESS"  # Explicit direction in code
  source_ranges = each.value.from_ranges
  target_tags   = each.value.target_tags
  
  allow { 
    protocol = "tcp"
    ports    = each.value.to_ports 
  }
  
  # Common parameters
  project = var.project_id
  network = var.network_name
  priority = 1000
}