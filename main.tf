terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}

module "network" {
  source = "./modules/network"

  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.required_apis]
}

module "storage" {
  source = "./modules/storage"

  project_id      = var.project_id
  region          = var.region
  db_name         = var.db_name
  db_user         = var.db_user
  db_password     = var.db_password
  db_tier         = var.db_tier
  private_network = module.network.private_network_id

  depends_on = [
    google_project_service.required_apis,
    module.network
  ]
}

# Backend Module
module "backend" {
  source = "./modules/backend"

  project_id        = var.project_id
  region            = var.region
  backend_port      = var.backend_port
  db_name           = var.db_name
  db_user           = var.db_user
  db_password       = var.db_password
  db_host           = module.storage.database_private_ip
  vpc_connector_id  = module.network.vpc_connector_id
  artifact_registry = module.network.artifact_registry_url

  depends_on = [
    google_project_service.required_apis,
    module.network,
    module.storage
  ]
}

# Frontend Module
module "frontend" {
  source = "./modules/frontend"

  project_id        = var.project_id
  region            = var.region
  nginx_port        = var.nginx_port
  backend_url       = module.backend.backend_url
  artifact_registry = module.network.artifact_registry_url
  backend_port      = var.backend_port

  depends_on = [
    google_project_service.required_apis,
    module.network,
    module.backend
  ]
}