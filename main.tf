locals {
  config_files = fileset("${path.module}/configs", "*.json")
  
  # For each file, decode it into an array of objects. Then flatten all arrays.
  all_configs = flatten([
    for file in local.config_files : jsondecode(file("${path.module}/configs/${file}"))
  ])
  
  # Build a flattened list of all ingress rules with extra attributes merged in from the parent config
  ingress_rules = flatten([
    for cfg in local.all_configs : [
      for rule in cfg.ingress : merge(rule, {
        carid   = cfg.carid,
        project = cfg.project,
        vpc     = cfg.vpc
      })
    ]
  ])
  
  # Build a flattened list of all egress rules with extra attributes merged in from the parent config
  egress_rules = flatten([
    for cfg in local.all_configs : [
      for rule in cfg.egress : merge(rule, {
        carid   = cfg.carid,
        project = cfg.project,
        vpc     = cfg.vpc
      })
    ]
  ])
}

module "firewall_ingress" {
  # Create a unique key for each ingress rule by combining carid with an index
  for_each = { for idx, rule in local.ingress_rules : "${rule.carid}-${idx}" => rule }
  
  source    = "./modules/firewall"
  rule_name = each.value.rule_name
  project   = each.value.project
  vpc       = each.value.vpc
  direction = "INGRESS"
  priority  = each.value.priority
  protocol  = each.value.protocol
  ports     = each.value.ports
  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags
}

module "firewall_egress" {
  # Create a unique key for each egress rule
  for_each = { for idx, rule in local.egress_rules : "${rule.carid}-${idx}" => rule }
  
  source    = "./modules/firewall"
  rule_name = each.value.rule_name
  project   = each.value.project
  vpc       = each.value.vpc
  direction = "EGRESS"
  priority  = each.value.priority
  protocol  = each.value.protocol
  ports     = each.value.ports
  destination_ranges = each.value.destination_ranges
  target_tags        = each.value.target_tags
}
