locals {
  config_files = fileset("${path.module}/configs", "*.json")
  configs_list = [for file in local.config_files : jsondecode(file("${path.module}/configs/${file}"))]
  team_configs = { for cfg in local.configs_list : cfg.carid => cfg }
}

module "firewall_ingress" {
  for_each = local.team_configs

  source    = "./modules/firewall"
  rule_name = lookup(each.value.ingress, "rule_name", "${each.key}-ingress")
  vpc       = each.value.vpc
  project   = each.value.project
  direction = "INGRESS"
  priority       = each.value.ingress.priority
  protocol       = each.value.ingress.protocol
  ports          = each.value.ingress.ports
  source_ranges  = each.value.ingress.source_ranges
  target_tags    = each.value.ingress.target_tags
  destination_ranges = []  # Not used for ingress
}

module "firewall_egress" {
  for_each = local.team_configs

  source    = "./modules/firewall"
  rule_name = lookup(each.value.egress, "rule_name", "${each.key}-egress")
  vpc       = each.value.vpc
  project   = each.value.project
  direction = "EGRESS"
  priority           = each.value.egress.priority
  protocol           = each.value.egress.protocol
  ports              = each.value.egress.ports
  destination_ranges = each.value.egress.destination_ranges
  target_tags        = each.value.egress.target_tags
  source_ranges      = []  # Not used for egress
}

