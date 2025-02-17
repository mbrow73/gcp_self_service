resource "google_compute_firewall" "this" {
  name    = var.rule_name
  project = var.project
  network = var.vpc

  direction = var.direction
  priority  = var.priority

  allow {
    protocol = var.protocol
    ports    = var.ports
  }

  source_ranges      = var.direction == "INGRESS" ? var.source_ranges : []
  destination_ranges = var.direction == "EGRESS" ? var.destination_ranges : []

  target_tags = var.target_tags
}
