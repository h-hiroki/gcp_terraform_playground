output "self_link" {
  description = "A self link og an instance"
  value       = google_compute_instance.default.self_link
}
