variable "namespace" {
  type        = string
  description = "namespace of the Helm release"
  default     = "default"
}

variable "name" {
  type        = string
  description = "name of the Helm release"
  default     = "postgres-operator"
}

variable "values" {
  description = "Helm release values. See submodules/postgres-operator/helm/install/values.yaml"
  default     = {}
}
