variable "egress_rules" {
  type = list(object({
    rule_name   = string
    to_ranges   = list(string)
    via_ports   = list(number)
    target_tags = list(string)
  }))
}

resource "google_compute_firewall" "egress" {
  for_each = { for rule in var.egress_rules : rule.rule_name => rule }

  name        = each.value.rule_name
  direction   = "EGRESS"
  destination_ranges = each.value.to_ranges
  target_tags = each.value.target_tags

  allow {
    protocol = "tcp"
    ports    = each.value.via_ports
  }

  project = var.project_id
  network = var.network_name
  priority = 1000
}