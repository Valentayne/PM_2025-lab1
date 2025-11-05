output "backend_url" {
  value = google_cloud_run_service.backend.status[0].url
}

output "backend_internal_url" {
  value = "${google_cloud_run_service.backend.name}-run.${var.region}.run.app"
}