provider "google" {
    credentials = var.GOOGLE_CREDENTIALS
    project     = var.project
    region      = "us-central1"
}