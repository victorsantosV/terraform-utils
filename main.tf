terraform {
  required_providers {
   google = {
        source="hashicorp/google"
        version="3.5.0"
      }
   }
}

provider "google" {
 credentials = file("test.json")
 project = "${var.credentials_google_project}"
 region = "${var.credentials_google_region}"
 zone = "${var.credentials_google_zone}"
}

provider "google-beta" {
 credentials = file("test.json")
 project = "${var.credentials_google_project}"
 region = "${var.credentials_google_region}"
 zone = "${var.credentials_google_zone}"
}

resource "google_service_account" "default" {
  account_id   = "${var.credentials_google_project}"
  display_name = "finanto_administrator"
}

## ==== Create a cluster ===== ##
resource "google_container_cluster" "primary" {
  name               = "${var.google_container_cluster_name}"
  location           = "${var.credentials_google_zone}"
  initial_node_count = 1

  node_config {
    service_account = google_service_account.default.email
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

## ==== Create Fixed IP ===== ##
resource "google_compute_global_address" "k8s_terraform_static_ip" {
  name = "${var.k8s_terraform_static_ip}"
}

## ==== Create ssl certificatad ===== ##
resource "google_compute_managed_ssl_certificate" "default" {
    provider = "google-beta"
    name = "signal-dev-finanto-io"
    managed {
        domains = ["signal-dev.finanto.io"]
    }
}
