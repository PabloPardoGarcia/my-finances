variable "storage_class_name" {
  type = string
  description = "Storage Class Name"
}

variable "create_pvc" {
  type = bool
  description = "When true (default), it creates a pvc"
  default = true
}

variable "pv_name" {
  type = string
  description = "Local Volume Name"
}

variable "pv_capacity" {
  type = string
  description = "Local Volume Capacity"
}

variable "pv_path" {
  type = string
  description = "Local Volume Path"
}

variable "pv_access_modes" {
  type = list(string)
  description = "Local Volume access modes"
  default = ["ReadWriteOnce"]
}

variable "pv_node_names" {
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
  default = ""
  nullable = false
}

variable "namespace" {
  type = string
  description = "PVC Namespace"
}

variable "db_name" {
  type = string
  description = "PostgreSQL service name"
}