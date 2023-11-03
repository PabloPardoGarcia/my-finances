output "pv-name" {
  value = kubernetes_persistent_volume_v1.local-volume.metadata.0.name
}

output "pvc-name" {
  value = kubernetes_persistent_volume_claim_v1.local-pvc.metadata.0.name
}