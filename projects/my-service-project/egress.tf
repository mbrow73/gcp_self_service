# OUTBOUND CONNECTIONS
module "db_access" {
  source = "../modules/egress_allow"

  project_id    = "eminent-torch-451100-r2"
  network_name  = "default"

  egress_rules = [{
    rule_name   = "egress-postgres",    # Direction in name
    to_ranges   = ["10.100.20.0/24"],   # TO these IPs
    via_ports   = [5432],               # THROUGH these ports
    target_tags = ["app-servers"],      # FROM these VMs
  }]
}