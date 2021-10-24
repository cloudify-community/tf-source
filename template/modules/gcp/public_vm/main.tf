terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~>3.87"
        }
    }
}

provider "google" {
    credentials = var.credentials_json
    project = var.project
    # region = var.region
    zone = var.zone

}

resource "random_id" "suffix" {
    byte_length = 4
}

resource "google_compute_network" "network" {
    name                    = "${var.prefix}-net-${random_id.suffix.hex}"
    auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "firewall" {
    name    = "${var.prefix}-firewall-${random_id.suffix.hex}"
    network = google_compute_network.network.self_link

    allow {
        protocol = "tcp"
        ports    = ["22"]
    }
}

resource "google_compute_instance" "vm" {
    name         = "${var.prefix}-vm-${random_id.suffix.hex}"
    machine_type = "f1-micro"

    metadata = {
        ssh-keys = "${var.admin_user}:${var.admin_key_public}"
    }

    boot_disk {
        initialize_params {
            image = "${var.image.project}/${var.image.family}"
        }
    }

    network_interface {
        network = google_compute_network.network.self_link
        access_config {}
    }
}

output "public_ip" {
    value = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}

