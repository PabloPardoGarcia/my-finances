variable "namespace" {
  type = string
  description = "My Finances namespace"
}

variable "dbt_deployment_name" {
  type = string
  description = "dbt deployment name"
}

variable "dbt_pv_path_to_app" {
  type = string
  description = "Path to dbt app files in the volume"
}

variable "dbt_pv_path_to_profiles" {
  type = string
  description = "Path to profile file in the volume"
}

variable "dbt_pvc_name" {
  type = string
  description = "dbt PVC Name"
}

variable "dbt_pv_name" {
  type = string
  description = "dbt PV Name"
}

variable "dbt_image" {
  type = string
  description = "dbt image name"
}

variable "dbt_labels" {
  type = map(string)
  description = "Labels to attach to the dbt components"
  default = {"app": "dbt"}
}