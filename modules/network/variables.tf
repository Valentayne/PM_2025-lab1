variable "vpc_cidr" {
  description = "CIDR блок для VPC"
  type        = map(string)
  default ={
    "10.0.1.0/28"
    "10.0.2.0/28"
  }
}

variable "region" {
  description = "GCP регіон, у якому створюється інфраструктура"
  type        = string
}

variable "tags" {
  description = "Загальні теги для мережевих ресурсів"
  type        = map(string)
  default     = { 
    Environment = "prod"
   }
}
