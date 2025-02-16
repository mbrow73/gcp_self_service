// Removed provider block – we rely on the root-level provider.

// Call the firewall_rules module:
module "firewall_rules" {
  source         = "../firewall_rules"
  project_id     = var.project_id
  network        = var.network
  firewall_rules = var.firewall_rules
}

// (No output defined here; outputs will be defined in outputs.tf)
