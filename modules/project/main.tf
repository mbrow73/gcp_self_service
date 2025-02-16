provider "google" {
  project = var.project_id
  region  = var.region
}

module "firewall_rules" {
  source         = "../firewall_rules"
  project_id     = var.project_id
  network        = var.network  // Defaults to "default".
  firewall_rules = var.firewall_rules
}

output "firewall_rule_ids" {
  value = module.firewall_rules.firewall_rule_ids
}
