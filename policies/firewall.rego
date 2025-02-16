package firewall

# Block public ingress on risky ports
deny[msg] {
  input.resource_changes[_].type == "google_compute_firewall"
  rule := input.resource_changes[_].change.after
  rule.direction == "INGRESS"
  any_public_source(rule.source_ranges)
  risky_port(rule.allow[_].ports[_])
  msg := sprintf("Public %s access on port %v prohibited", [rule.direction, risky_port])
}

any_public_source(ranges) {
  ranges[_] == "0.0.0.0/0"
}

risky_port(port) {
  port == 22    # SSH
}

risky_port(port) {
  port == 3389  # RDP
}


# Enforce naming conventions
deny[msg] {
  input.resource_changes[_].type == "google_compute_firewall"
  rule := input.resource_changes[_].change.after
  not valid_rule_name(rule.name, rule.direction)
  msg := sprintf("Rule name must start with %s- prefix", [rule.direction])
}

valid_rule_name(name, direction) {
  startswith(name, sprintf("%s-", [direction]))
}

# Validate CIDR formats
deny[msg] {
  input.resource_changes[_].type == "google_compute_firewall"
  rule := input.resource_changes[_].change.after
  invalid_cidr(rule.source_ranges[_])
  msg := sprintf("Invalid source CIDR: %s", [invalid_cidr])
}

invalid_cidr(cidr) {
  not net.cidr_is_valid(cidr)
}