resource "kubernetes_namespace" "superset_namespace" {
  metadata {
    name = var.superset_namespace
  }
}

resource "helm_release" "superset_release" {
  name = "superset"
  repository = "https://apache.github.io/superset"
  chart = "superset"

  version = var.superset_helm_version
  namespace = var.superset_namespace

  # Overwrite helm chart values.yaml
#  values = []
}