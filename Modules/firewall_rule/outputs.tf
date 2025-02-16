output "firewall_rule_ids" {
  value       = { for key, fw in google_compute_firewall.this : key => fw.id }
  description = "Map of firewall rule names to their IDs."
}
