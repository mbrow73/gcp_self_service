provider "google" {
    credentials = var.GOOGLE_CREDENTIALS
    project     = var.GOOGLE_PROJECT_ID
    region      = "us-central1"
}