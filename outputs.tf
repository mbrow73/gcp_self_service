output "firewall_rules" {
  description = "Map of created firewall rules"
  value       = { for k, v in module.team_firewall_rules : k => v }
}