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

variable "uploader_image" {
  type = string
  description = "uploader image name"
}

variable "storage_class_name" {
  type = string
  description = "Storage Class Name"
  default = "local-storage-class"
}

variable "site_url" {
  type = string
  description = "Site URL"
}