// Iterate over each project defined in var.projects.
module "projects" {
  source   = "./modules/project"
  for_each = var.projects

  project_id     = each.value.project_id
  region         = each.value.region
  firewall_rules = each.value.firewall_rules
}

output "project_firewall_rule_ids" {
  value = { for proj, mod in module.projects : proj => mod.firewall_rule_ids }
}
