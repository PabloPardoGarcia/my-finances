variable "ingres_controller_namespace" {
  type = string
  description = "Namespace where to deploy the ingress controller"
  default = "ingress-nginx"
}

variable "namespace" {
  type = string
  description = "Namespace where to deploy the ingress controller"
}

variable "helm_version" {
  type = string
  description = "ingress-nginx controller helm version"
  default = "4.8.3"
}

variable "site_url" {
  type = string
  description = "Site URL"
}

variable "dbt_service_name" {
  type = string
  description = "dbt service name"
}

variable "api_service_name" {
  type = string
  description = "API service name"
}