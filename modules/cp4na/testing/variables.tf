variable "region" {}
variable "resource_group_name" {}
variable "cluster_id" {}

variable "enable" {
  default     = true
  type        = bool
  description = "If set to true installs Cloud-Pak for Security on the given cluster"
}

variable "cluster_config_path" {
  type        = string
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}