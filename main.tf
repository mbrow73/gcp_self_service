terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Use a common provider; note that each google_compute_firewall resource can override the project.
provider "google" {
  project = "testautomation-451116"  # This is a fallback; actual project is set per resource
  region  = "us-central1"
}

locals {
  # List all JSON config files under configs/
  config_files = fileset("${path.module}/configs", "*.json")

  # Decode each JSON file into an object
  configs_list = [for file in local.config_files : jsondecode(file("${path.module}/configs/${file}"))]

  # Build a map keyed by team name (each JSON must include a "name" attribute)
  team_configs = { for cfg in local.configs_list : cfg.name => cfg }
}

# Create an ingress firewall rule for each team
module "firewall_ingress" {
  for_each = local.team_configs

  source    = "./modules/firewall"
  name      = "${each.key}-ingress"
  vpc       = each.value.vpc       # vpc is provided in the JSON
  project   = each.value.project   # project is provided in the JSON
  direction = "INGRESS"

  priority       = each.value.ingress.priority
  protocol       = each.value.ingress.protocol
  ports          = each.value.ingress.ports
  source_ranges  = each.value.ingress.source_ranges
  target_tags    = each.value.ingress.target_tags

  # Not used for ingress
  destination_ranges = []
}

# Create an egress firewall rule for each team
module "firewall_egress" {
  for_each = local.team_configs

  source    = "./modules/firewall"
  name      = "${each.key}-egress"
  vpc       = each.value.vpc
  project   = each.value.project
  direction = "EGRESS"

  priority           = 1000
  protocol           = each.value.egress.protocol
  ports              = each.value.egress.ports
  destination_ranges = each.value.egress.destination_ranges
  target_tags        = each.value.egress.target_tags

  # Not used for egress
  source_ranges = []
}
