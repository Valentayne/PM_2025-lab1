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
  type      = string
  sensitive = true
}

variable "db_tier" {
  type = string
}

variable "private_network" {
  type = string
}