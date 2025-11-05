resource "google_sql_database_instance" "db" {
  name             = "main-instance"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = false 

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network_id
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.db.name
  password = var.db_password
}

resource "null_resource" "init_table" {
  depends_on = [google_sql_database_instance.db]

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD=${var.db_password} psql \
      -h ${google_sql_database_instance.db.private_ip_address} \
      -U ${var.db_user} \
      -d ${var.db_name} \
      -f ${path.module}/init.sql
    EOT
  }
}
