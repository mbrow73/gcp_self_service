package firewall

# Rule 1: Enforce naming convention - names must start with "allow-"
deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  not startswith(resource.values.name, "allow-")
  msg := sprintf("Firewall rule '%v' does not follow naming convention (must start with 'allow-')", [resource.values.name])
}

# Rule 2: Disallow public access (0.0.0.0/0) for SSH (port 22) on INGRESS
deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  resource.values.direction == "INGRESS"
  some i
  rule := resource.values.allowed[i]
  rule.protocol == "tcp"
  "22" in rule.ports
  "0.0.0.0/0" in resource.values.source_ranges
  msg := sprintf("Firewall rule '%v' exposes SSH (port 22) from public sources", [resource.values.name])
}

# Rule 3: Disallow public access (0.0.0.0/0) for RDP (port 3389) on INGRESS
deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  resource.values.direction == "INGRESS"
  some i
  rule := resource.values.allowed[i]
  rule.protocol == "tcp"
  "3389" in rule.ports
  "0.0.0.0/0" in resource.values.source_ranges
  msg := sprintf("Firewall rule '%v' exposes RDP (port 3389) from public sources", [resource.values.name])
}

# Rule 4: Disallow use of 0.0.0.0/0 (quad 0) in any CIDR fields if not explicitly permitted.
# (This example denies any firewall rule that uses 0.0.0.0/0 unless the rule name includes "public-allowed".)
deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  cidr := resource.values.source_ranges[_]
  cidr == "0.0.0.0/0"
  not contains(resource.values.name, "public-allowed")
  msg := sprintf("Firewall rule '%v' uses 0.0.0.0/0 in source_ranges without proper naming (must include 'public-allowed' to permit)", [resource.values.name])
}

deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  cidr := resource.values.destination_ranges[_]
  cidr == "0.0.0.0/0"
  not contains(resource.values.name, "public-allowed")
  msg := sprintf("Firewall rule '%v' uses 0.0.0.0/0 in destination_ranges without proper naming (must include 'public-allowed' to permit)", [resource.values.name])
}

# Rule 5: Validate CIDR format for each CIDR entry in source_ranges and destination_ranges.
# (This is a simple regex check; adjust as needed.)
deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  cidr := resource.values.source_ranges[_]
  not regex.match("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", cidr)
  msg := sprintf("Firewall rule '%v' has an invalid CIDR in source_ranges: %v", [resource.values.name, cidr])
}

deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "google_compute_firewall"
  cidr := resource.values.destination_ranges[_]
  not regex.match("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", cidr)
  msg := sprintf("Firewall rule '%v' has an invalid CIDR in destination_ranges: %v", [resource.values.name, cidr])
}
