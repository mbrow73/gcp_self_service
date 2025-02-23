locals {
  config_files = fileset("${path.module}/configs", "*.json")
  
  # Each file contains an array of config objects; flatten them into one list.
  all_configs = flatten([
    for file in local.config_files : jsondecode(file("${path.module}/configs/${file}"))
  ])
  
  # Flatten all ingress rules across all configuration objects,
  # and merge the parent attributes (carid, project, vpc) into each rule.
  ingress_rules = flatten([
    for cfg in local.all_configs : [
      for rule in cfg.ingress : merge(rule, {
        carid   = cfg.carid,
        project = cfg.project,
        vpc     = cfg.vpc
      })
    ]
  ])
  
  # Flatten all egress rules across all configuration objects.
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
  # Create a unique key for each ingress rule.
  for_each = { for idx, rule in local.ingress_rules : "${rule.carid}-${idx}" => rule }
  
  source    = "./modules/firewall"
  rule_name = each.value.rule_name
  project   = each.value.project
  vpc       = each.value.vpc
  direction = "INGRESS"
  priority  = 1000
  protocol  = each.value.protocol
  ports     = each.value.ports
  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags
}

module "firewall_egress" {
  # Create a unique key for each egress rule.
  for_each = { for idx, rule in local.egress_rules : "${rule.carid}-${idx}" => rule }
  
  source    = "./modules/firewall"
  rule_name = each.value.rule_name
  project   = each.value.project
  vpc       = each.value.vpc
  direction = "EGRESS"
  priority  = 1000
  protocol  = each.value.protocol
  ports     = each.value.ports
  destination_ranges = each.value.destination_ranges
  target_tags        = each.value.target_tags
}

## default rules fw testing ##

# Create a centralized firewall policy for default rules like ofac/threat intel/default egress deny. Exceptions are required to pass expected traffic to lower level rules (VPC firewall) #
resource "google_compute_firewall_policy" "default_deny_policy" {
  short_name  = "default-deny-egress"
  parent      = var.folder_id
  description = "Firewall policy to deny all egress traffic by default for all projects under prod folder"
}

## Associate the default deny policy with the folder ##
resource "google_compute_firewall_policy_association" "default" {
  firewall_policy = google_compute_firewall_policy.default_deny_policy.id
  attachment_target = var.folder_id
  name = "my-association"
}




### EGRESS RULES ###

## pass known traffic to vpc firewall rules ##
resource "google_compute_firewall_policy_rule" "gotonext_all_egress" {
  firewall_policy         = google_compute_firewall_policy.default_deny_policy.id
  description             = "Resource created for Terraform acceptance testing"
  priority                = 1
  enable_logging          = true
  action                  = "allow"
  direction               = "EGRESS"
  disabled                = false
  target_service_accounts = []

  match {
    dest_ip_ranges            = ["172.16.0.0/12", "192.168.0.0/16"]
    src_ip_ranges             = []
    dest_fqdns                = []
    src_fqdns                 = []
    dest_region_codes         = []
    dest_threat_intelligences = []

    layer4_configs {
      ip_protocol = "all"
      ports       = [""]
    }
  }
}

## deny all other traffic ##
resource "google_compute_firewall_policy_rule" "deny_all_egress" {
  firewall_policy         = google_compute_firewall_policy.default_deny_policy.id
  description             = "Resource created for Terraform acceptance testing"
  priority                = 1000
  enable_logging          = true
  action                  = "deny"
  direction               = "EGRESS"
  disabled                = false
  target_service_accounts = []

  match {
    dest_ip_ranges            = ["0.0.0.0/0"]
    src_ip_ranges             = []
    dest_fqdns                = []
    src_fqdns                 = []
    dest_region_codes         = []
    dest_threat_intelligences = []

    layer4_configs {
      ip_protocol = "all"
      ports       = [""]
    }
  }
}
### INGRESS RULES ###


## pass known traffic to vpc firewall rules ##
resource "google_compute_firewall_policy_rule" "gotonext_all_ingress" {
  firewall_policy         = google_compute_firewall_policy.default_deny_policy.id
  description             = "Resource created for Terraform acceptance testing"
  priority                = 2
  enable_logging          = true
  action                  = "allow"
  direction               = "INGRESS"
  disabled                = false
  target_service_accounts = []

  match {
    src_ip_ranges             = ["172.16.0.0/12", "192.168.0.0/16", "38.156.212.133/32"]
    dest_ip_ranges            = []
    src_fqdns                 = []
    dest_fqdns                = []
    src_region_codes          = []
    src_threat_intelligences  = []

    layer4_configs {
      ip_protocol = "all"
      ports       = [""]
    }
  }
}


## deny all other traffic ##
resource "google_compute_firewall_policy_rule" "deny_all_ingress" {
  firewall_policy         = google_compute_firewall_policy.default_deny_policy.id
  description             = "Resource created for Terraform acceptance testing"
  priority                = 999
  enable_logging          = true
  action                  = "deny"
  direction               = "INGRESS"
  disabled                = false
  target_service_accounts = []

  match {
    src_ip_ranges             = ["0.0.0.0/0"]
    dest_ip_ranges            = []
    src_fqdns                 = []
    dest_fqdns                = []
    src_region_codes          = []
    src_threat_intelligences  = []

    layer4_configs {
      ip_protocol = "all"
      ports       = [""]
    }
  }
}