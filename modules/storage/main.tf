# modules/storage/main.tf

# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "db" {
  name                = "main-instance"
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = false
  
  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"
    
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network_id
    }
    
  }

}

# Cloud SQL Database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.db.name
}

# Cloud SQL User
resource "google_sql_user" "db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.db.name
  password = var.db_password
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# Ініціалізація таблиці через SQL файл
resource "null_resource" "init_db_table" {
  depends_on = [
    google_sql_database.database,
    google_sql_user.db_user
  ]
  
  triggers = {
    # Перезапускати якщо змінився інстанс або база
    instance_id = google_sql_database_instance.db.id
    database_id = google_sql_database.database.id
    # Перезапустити якщо SQL файл змінився
    sql_file_hash = filemd5("${path.module}/init.sql")
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for database to be ready..."
      sleep 30
      
      echo "Connecting to database and executing init.sql..."
      gcloud sql connect ${google_sql_database_instance.db.name} \
        --user=${var.db_user} \
        --database=${var.db_name} \
        --quiet < ${path.module}/init.sql
      
      echo "Database initialization completed!"
    EOT
    
    environment = {
      PGPASSWORD = var.db_password
    }
  }
  
  provisioner "local-exec" {
    when    = create
    command = "echo 'Database table initialization triggered for ${var.db_name}'"
  }
}