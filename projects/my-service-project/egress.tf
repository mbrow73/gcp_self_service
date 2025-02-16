# OUTBOUND CONNECTIONS
module "db_access" {
  source = "modules/egress_allow"

  project_id    = "team-project-123"
  network_name  = "secure-vpc"

  egress_rules = [{
    rule_name   = "egress-postgres",    # Direction in name
    to_ranges   = ["10.100.20.0/24"],   # TO these IPs
    via_ports   = [5432],               # THROUGH these ports
    target_tags = ["app-servers"],      # FROM these VMs
    priority    = 1000
  }]
}