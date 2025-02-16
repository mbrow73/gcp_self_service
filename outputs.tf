output "firewall_rules" {
  description = "Map of created firewall rules"
  value       = { for k, v in module.firewall_rule : k => v }
}