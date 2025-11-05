variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_host" {
  type = string
}

variable "vpc_connector_id" {
  type = string
}

variable "artifact_registry" {
  type = string
}