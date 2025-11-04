resource "google_sql_database_instance" "db" {
  name             = "mydb"
  database_version = "POSTGRES_15"
  region           = "europe-central2"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}