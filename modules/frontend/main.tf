resource "google_cloud_run_service" "frontend" {
  name     = "frontend"
  location = var.region

  template {
    spec {
      containers {
        image = var.artifact_registry

        env = [
          { name = "BACKEND_URL", value = var.backend_url }
        ]

        ports {
          container_port = var.nginx_port
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
