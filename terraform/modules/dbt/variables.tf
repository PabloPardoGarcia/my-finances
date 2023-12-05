variable "namespace" {
  type = string
  description = "My Finances namespace"
}

variable "dbt_image" {
  type = string
  description = "dbt image name"
}

variable "postgres_service_name" {
  type = string
  description = "PostrgreSQL service name"
}

variable "postgres_secrets_name" {
  type = string
  description = "Name of the PostrgreSQL secret with the credentials"
}

variable "docker_config_secret" {
  type = string
  description = "Secret name containing the dockerconfigjson"
}