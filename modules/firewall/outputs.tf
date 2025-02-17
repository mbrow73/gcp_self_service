output "firewall_rule_name" {
  description = "The name of the created firewall rule."
  value       = google_compute_firewall.this.name
}
