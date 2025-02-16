provider "google" {
  project = var.project_id
  region  = var.region
}

module "firewall_rules" {
  source     = "../../modules/firewall_rules"
  project_id = var.project_id
  network    = "default"

  firewall_rules = var.firewall_rules
}