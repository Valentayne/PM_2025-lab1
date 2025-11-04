resource "google_sql_database_instance" "db" {
  name             = "app-database"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network
    }
  }
}

resource "google_sql_database" "db_name" {
  name     = var.db_name
  instance = google_sql_database_instance.db.name
}

resource "google_sql_user" "db_user" {
  name     = var.db_user
  password = var.db_password
  instance = google_sql_database_instance.db.name
}