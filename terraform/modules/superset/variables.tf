variable "superset_namespace" {
  type = string
  description = "Superset namespace"
}

variable "superset_helm_version" {
  type = string
  description = "Superset helm version"
  default = "0.10.11"
}