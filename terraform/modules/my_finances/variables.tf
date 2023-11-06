variable "namespace" {
  type = string
  description = "My Finances namespace"
}

variable "labels" {
  type = map(string)
  description = "Labels to attach to the resources generated by my-finances module"
  default = {"app": "my-finances"}
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

#variable "postgres_user" {
#  type = string
#  description = "Postgres DB User"
#  sensitive = true
#}
#
#variable "postgres_password" {
#  type = string
#  description = "Postgres DB Password"
#  sensitive = true
#}
#
#variable "postgres_db_name" {
#  type = string
#  description = "Postgres DB Name"
#  sensitive = true
#}