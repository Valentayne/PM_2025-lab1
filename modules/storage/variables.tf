variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "db_name" {
  type = string
  default = "name_affiliation"
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_tier" {
  type = string
}

variable "db_port" {
  type    = string
  default = "5432"
}

variable "private_network_id" {
  type = string
}
