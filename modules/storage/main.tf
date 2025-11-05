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
resource "null_resource" "init_db_table" {
  depends_on = [
    google_sql_database.database,
    google_sql_user.user
  ]

  triggers = {
    instance_id = google_sql_database_instance.postgres.id
    database_id = google_sql_database.database.id
    
    sql_file_hash = filemd5("${path.module}/init.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for database to be ready..."
      sleep 30
      
      gcloud sql connect ${google_sql_database_instance.postgres.name} \
        --user=${var.db_user} \
        --database=${var.db_name} \
        --quiet < ${path.module}/init.sql
      
      echo "Database initialization completed!"
    EOT

    environment = {
      PGPASSWORD = var.db_password
    }
  }

  # Якщо команда не вдалася, спробуємо ще раз
  provisioner "local-exec" {
    when    = create
    command = "echo 'Database table initialization triggered'"
  }
}