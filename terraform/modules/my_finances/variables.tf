variable "namespace" {
  type = string
  description = "My Finances namespace"
}

variable "dbt_pv_path_to_app" {
  type = string
  description = "Path to dbt app files in the volume"
}

variable "dbt_pv_path_to_profiles" {
  type = string
  description = "Path to profile file in the volume"
}

variable "dbt_image" {
  type = string
  description = "dbt image name"
}

variable "storage_class_name" {
  type = string
  description = "Storage Class Name"
  default = "local-storage-class"
}