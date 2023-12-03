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