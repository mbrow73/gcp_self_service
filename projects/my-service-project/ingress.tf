module "web_access" {
  source = "../modules/ingress_allow"

  project_id    = "eminent-torch-451100-r2"
  network_name  = "default"

  ingress_rules = [{
    rule_name   = "ingress-web-https",  # Direction in name
    from_ranges = ["203.0.113.0/24"],   # FROM these IPs
    to_ports    = [443],                # TO these ports
    target_tags = ["web-servers"],      # ON these VMs
  }]
}