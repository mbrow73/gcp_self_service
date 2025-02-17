variable "name" {
  description = "The name of the firewall rule."
  type        = string
}

variable "project" {
  description = "The GCP project for the firewall rule."
  type        = string
}

variable "vpc" {
  description = "The VPC (network) to attach the firewall rule to."
  type        = string
}

variable "direction" {
  description = "Traffic direction: INGRESS or EGRESS."
  type        = string
}

variable "priority" {
  description = "Priority for the firewall rule."
  type        = number
  default     = 1000
}

variable "protocol" {
  description = "The protocol to allow (e.g., tcp, udp)."
  type        = string
}

variable "ports" {
  description = "List of ports or port ranges to allow."
  type        = list(string)
}

variable "source_ranges" {
  description = "List of source IP ranges for ingress rules."
  type        = list(string)
  default     = []
}

variable "destination_ranges" {
  description = "List of destination IP ranges for egress rules."
  type        = list(string)
  default     = []
}

variable "target_tags" {
  description = "List of target tags to apply the firewall rule."
  type        = list(string)
  default     = []
}
