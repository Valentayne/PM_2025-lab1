resource "google_cloud_run_service" "backend" {
  name     = "backend"
  location = var.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_id
      }
    }

    spec {
      containers {
        image = "${var.artifact_registry}/backend:latest"

        env {
          name  = "DB_NAME"
          value = var.db_name
        }

        env {
          name  = "DB_USER"
          value = var.db_user
        }

        env {
          name  = "DB_PASS"
          value = var.db_password
        }

        env {
          name  = "DB_HOST"
          value = var.db_host
        }

        env {
          name  = "DB_PORT"
          value = var.db_port
        }

      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "backend_invoker" {
  service  = google_cloud_run_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}


output "backend_url" {
  value = google_cloud_run_service.backend.status[0].url
}
