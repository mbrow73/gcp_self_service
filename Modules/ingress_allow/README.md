# Inbound Traffic Rules

## Template Fields
| Parameter    | Description                | Example               |
|--------------|----------------------------|-----------------------|
| `from_ranges`| Source IP CIDRs            | ["203.0.113.0/24"]    |
| `to_ports`   | Destination Ports          | [443]                 |
| `target_tags`| Recipient VM Tags          | ["web-servers"]       |


### copy and paste the below code into your project's egress.tf file and
module "web_access" {
  source = "modules/ingress_allow"

  project_id    = "team-project-123"
  network_name  = "secure-vpc"

  ingress_rules = [{
    rule_name   = "ingress-web-https",  # Direction in name
    from_ranges = [""],   # FROM these IPs
    to_ports    = [],                # TO these ports
    target_tags = [""],      # ON these VMs
  }]
}