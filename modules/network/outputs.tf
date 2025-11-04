output "vpc_connector_id" {
  value = google_vpc_access_connector.connector.id
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/app-images"
}

output "private_network_id" {
  value = google_compute_network.private_network.id
}
