variable "namespace" {
  type = string
  description = "Namespace where to deploy the ingress controller"
  default = "ingress-nginx"
}

variable "helm_version" {
  type = string
  description = "ingress-nginx controller helm version"
  default = "4.8.3"
}