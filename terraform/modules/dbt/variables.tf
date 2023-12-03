variable "namespace" {
  type = string
  description = "My Finances namespace"
}

variable "git_sync_path_to_dbt" {
  type = string
  description = "Path to dbt app files git git-sync repo"
}

variable "git_sync_path_to_dbt_profiles" {
  type = string
  description = "Path to profile file in the git-sync repo"
}

variable "git_sync_git_repo" {
  type = string
  description = "dbt repo url"
}

variable "git_sync_image" {
  type = string
  description = "git-sync docker image"
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