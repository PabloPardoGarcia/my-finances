output "pv_name" {
  value = kubernetes_persistent_volume_v1.local_volume.metadata.0.name
}

output "pvc_name" {
  value = one(kubernetes_persistent_volume_claim_v1.local_pvc[*].metadata.0.name)
}

output "pv_volume_capacity" {
  value = kubernetes_persistent_volume_v1.local_volume.spec.0.capacity.storage
}