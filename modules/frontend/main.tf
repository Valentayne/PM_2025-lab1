resource "google_service_account" "frontend_sa" {
  account_id   = "frontend-cloudrun-sa"
  display_name = "Frontend Cloud Run Service Account"
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend-service"
  location = var.region
  
  template {
    service_account = google_service_account.frontend_sa.email
    
    containers {
      image = "${var.artifact_registry}/frontend:latest"
      
      ports {
        container_port = var.nginx_port
      }
      
      env {
        name  = "PORT"
        value = tostring(var.nginx_port)
      }
      
      env {
        name  = "BACKEND_HOST"
        value = var.backend_url
      }
      
      env {
        name  = "BACKEND_PORT"
        value = tostring(var.backend_port)
      }
      
      resources {
        limits = {
          cpu    = "1"
          memory = "256Mi"
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