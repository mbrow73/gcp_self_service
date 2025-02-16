projects = {
  "sample-project" = {
    project_id = "testautomation-451116"
    region     = "us-central1"
    firewall_rules = [
      {
        name               = "allow-ssh-ingress"
        direction          = "INGRESS"
        source_ranges      = ["203.0.113.0/24"]
        destination_ranges = []                // Not used for INGRESS.
        target_tags        = ["ssh-access"]
        allowed = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]
      },
      {
        name               = "allow-egress-http"
        direction          = "EGRESS"
        source_ranges      = []                // Not used for EGRESS.
        destination_ranges = ["0.0.0.0/0"]
        target_tags        = ["web-server"]
        allowed = [
          {
            protocol = "tcp"
            ports    = ["80", "443"]
          }
        ]
      }
    ]
  }
}
