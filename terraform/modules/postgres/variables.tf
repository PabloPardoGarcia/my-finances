variable "postgres_namespace" {
  type = string
  description = "Namespace"
}

variable "postgres_pvc_name" {
  type = string
  description = "PVC Name"
}

variable "postgres_pv_name" {
  type = string
  description = "Postgres PV Name"
}

variable "postgres_name" {
  type = string
  description = "Postgres Name"
  default = "postgres"
}

variable "postgres_labels" {
  type = map(string)
  description = "Labels to attach to the postgres components"
  default = {"app": "postgres"}
}
