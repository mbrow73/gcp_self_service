terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.20.0"
    }
  }
}

provider "google" {
      credentials = (var.creds)
      project     = (var.project)
      region      = "us-central1"
}