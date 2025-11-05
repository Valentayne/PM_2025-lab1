# modules/storage/outputs.tf
output "database_private_ip" {
  description = "Приватна IP адреса Cloud SQL"
  value       = google_sql_database_instance.db.private_ip_address
}

output "database_connection_name" {
  description = "Connection name для Cloud SQL"
  value       = google_sql_database_instance.db.connection_name
}

output "database_instance_name" {
  description = "Назва інстансу Cloud SQL"
  value       = google_sql_database_instance.db.name
}

output "secret_id" {
  description = "Secret Manager secret ID"
  value       = google_secret_manager_secret.db_password.secret_id
}