resource "helm_release" "lightdash_release" {
  name = "lightdash"
  repository = "https://lightdash.github.io/helm-charts"
  chart = "lightdash"

  version = var.helm_version
  namespace = var.namespace

  # Overwrite helm chart values.yaml
  values = [
    file("${path.module}/values.yaml")
  ]
}