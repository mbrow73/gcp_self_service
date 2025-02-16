# Outbound Traffic Rules

## Template Fields
| Parameter    | Description                | Example               |
|--------------|----------------------------|-----------------------|
| `to_ranges`  | Destination IP CIDRs       | ["10.100.20.0/24"]    |
| `via_ports`  | Destination Ports          | [5432]                |
| `target_tags`| Source VM Tags             | ["app-servers"]       |


# copy and paste the below code into your project's egress.tf file. Make sure to fill placeholders with real values relevant to your project.
module "db_access" {
  source = "modules/egress_allow"

  project_id    = "team-project-123"
  network_name  = "secure-vpc"

  egress_rules = [{
    rule_name   = "egress-postgres",    # Direction in name
    to_ranges   = ["10.100.20.0/24"],   # TO these IPs
    via_ports   = [5432],               # THROUGH these ports
    target_tags = ["app-servers"],      # FROM these VMs
  }]
}