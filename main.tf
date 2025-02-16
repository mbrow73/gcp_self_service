terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.20.0"
    }
  }
}
provider "google" {
      credentials = (var.GOOGLE_CREDENTIALS)
      project     = (var.project)
}