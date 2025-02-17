resource "google_compute_firewall" "this" {
  name    = var.name
  project = var.project       # Deploy to the team’s project
  network = var.vpc           # The VPC in the team’s project

  direction = var.direction
  priority  = var.priority

  allow {
    protocol = var.protocol
    ports    = var.ports
  }

  dynamic "source_ranges" {
    for_each = var.direction == "INGRESS" ? [1] : []
    content {
      values = var.source_ranges
    }
  }

  dynamic "destination_ranges" {
    for_each = var.direction == "EGRESS" ? [1] : []
    content {
      values = var.destination_ranges
    }
  }

  target_tags = var.target_tags
}
