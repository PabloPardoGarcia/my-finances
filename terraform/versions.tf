terraform {
  required_version = "~>1.5.7"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}