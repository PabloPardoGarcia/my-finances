variable "namespace" {
  type = string
  description = "Lightdash namespace"
  default = "lightdash"
}

variable "helm_version" {
  type = string
  description = "Lightdash helm version"
  default = "0.8.9"
}

variable "site_url" {
  type = string
  description = "Site URL"
}