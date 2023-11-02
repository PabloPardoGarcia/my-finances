variable "storage_class_name" {
  type = string
  description = "Storage Class Name"
}

variable "local_volume_name" {
  type = string
  description = "Local Volume Name"
}

variable "local_volume_capacity" {
  type = string
  description = "Local Volume Capacity"
}

variable "local_volume_path" {
  type = string
  description = "Local Volume Path"
}

variable "local_volume_access_modes" {
  type = list(string)
  description = "Local Volume access modes"
  default = ["ReadWriteOnce"]
}

variable "local_volume_node_names" {
  type = list(string)
  description = "List of node names on which to make the local volume available"
}

variable "pvc_access_modes" {
  type = list(string)
  description = "PVC Access Modes"
  default = ["ReadWriteOnce"]
}

variable "pvc_name" {
  type = string
  description = "PVC Name"
}

variable "pvc_namespace" {
  type = string
  description = "PVC Namespace"
}