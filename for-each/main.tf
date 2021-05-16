data "google_compute_zones" "available" {
  region = "asia-northeast1"
  status = "UP"
}

resource "google_compute_instance" "default" {
  for_each = toset(data.google_compute_zones.available.names)

  name         = "test-${each.key}"
  machine_type = "f1-micro"
  zone         = "asia-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
  }
}

output "instance_names" {
  description = "Zone of instances"
  value       = values(google_compute_instance.default)[*].name
}

output "instance_zones" {
  description = "Zones of instances"
  value       = values(google_compute_instance.default)[*].zone
}
