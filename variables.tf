
variable "project" {
  type        = string
  description = "The GCP project ID." 
}

variable "GOOGLE_CREDENTIALS" {
  type        = string
  description = "The GCP project ID." 
}

variable "folder_id" {
  description = "The folder ID under which the projects reside"
  type        = string
  default     = "267070050069"  # Replace with your actual folder ID
}