locals {
  config_files = fileset("${path.module}/configs", "*.json")
  # For each file, decode it into an array of objects. Then flatten all arrays.
  all_configs = flatten([
    for file in local.config_files : jsondecode(file("${path.module}/configs/${file}"))
  ])
}

# To iterate over each configuration (even if multiple blocks have the same carid), create a unique key:
module "firewall_ingress" {
  for_each = { for idx, cfg in local.all_configs : "${cfg.carid}-${idx}" => cfg }
  
  source    = "./modules/firewall"
  rule_name = each.value.ingress[0].rule_name  # Example: if you want the first ingress block; otherwise, iterate further
  project   = each.value.project
  vpc       = each.value.vpc
  direction = "INGRESS"
  priority  = 1000
  protocol  = each.value.ingress[0].protocol
  ports     = each.value.ingress[0].ports
  source_ranges = each.value.ingress[0].source_ranges
  target_tags   = each.value.ingress[0].target_tags
}

# Similarly, you can create a module block for each egress rule block:
module "firewall_egress" {
  for_each = { for idx, cfg in local.all_configs : "${cfg.carid}-${idx}" => cfg }
  
  source    = "./modules/firewall"
  rule_name = each.value.egress[0].rule_name  # Example: if you want the first egress block; adjust as needed
  project   = each.value.project
  vpc       = each.value.vpc
  direction = "EGRESS"
  priority  = 1000
  protocol  = each.value.egress[0].protocol
  ports     = each.value.egress[0].ports
  destination_ranges = each.value.egress[0].destination_ranges
  target_tags        = lookup(each.value.egress[0], "target_tags", [])
}
