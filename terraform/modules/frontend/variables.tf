variable "namespace" {
  type = string
  description = "My Finances namespace"
}

variable "frontend_image" {
  type = string
  description = "API image name"
}

variable "docker_config_secret" {
  type = string
  description = "Secret name containing the dockerconfigjson"
}

variable "postgres_service_name" {
  type = string
  description = "PostrgreSQL service name"
}

variable "postgres_secrets_name" {
  type = string
  description = "Name of the PostrgreSQL secret with the credentials"
}