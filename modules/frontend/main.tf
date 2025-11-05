# modules/frontend/main.tf
# Service Account для Frontend Cloud Run
resource "google_service_account" "frontend_sa" {
  account_id   = "frontend-cloudrun-sa"
  display_name = "Frontend Cloud Run Service Account"
}

# Cloud Run Frontend Service
resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend-service"
  location = var.region
  
  template {
    service_account = google_service_account.frontend_sa.email
    
    containers {
      image = "${var.artifact_registry}/frontend:latest"
      
      env {
        name  = "BACKEND_URL"
        value = var.backend_url
      }
      ports {
        container_port = var.nginx_port
      }
      
      env {
        name  = "BACKEND_HOST"
        value = var.backend_url
      }
      
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      
      startup_probe {
        http_get {
          path = "/health"
          port = var.nginx_port
        }
        initial_delay_seconds = 5
        period_seconds        = 3
        timeout_seconds       = 2
        failure_threshold     = 10
      }
    }
    
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  name     = google_cloud_run_v2_service.frontend.name
  location = google_cloud_run_v2_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}