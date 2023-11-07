output "pv-name" {
  value = kubernetes_persistent_volume_v1.local-volume.metadata.0.name
}

output "pvc-name" {
  value = one(kubernetes_persistent_volume_claim_v1.local-pvc[*].metadata.0.name)
}

output "pv-volume-capacity" {
  value = kubernetes_persistent_volume_v1.local-volume.spec.0.capacity.storage
}