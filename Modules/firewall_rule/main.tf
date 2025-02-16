locals {
  # Create a map from the list of firewall rule objects keyed by each rule's name.
  firewall_rule_map = { for rule in var.firewall_rules : rule.name => rule }
}

resource "google_compute_firewall" "this" {
  for_each = local.firewall_rule_map

  name      = each.value.name
  project   = var.project_id
  network   = var.network
  direction = each.value.direction
  priority  = 1000

  dynamic "allow" {
    for_each = each.value.allowed
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  # Apply source_ranges for INGRESS and destination_ranges for EGRESS.
  source_ranges      = each.value.direction == "INGRESS" ? each.value.source_ranges : null
  destination_ranges = each.value.direction == "EGRESS" ? each.value.destination_ranges : null

  # Always use target_tags.
  target_tags = each.value.target_tags
}
