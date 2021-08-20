variable "operator_namespace" {}

variable "cluster_id" {
  description = "ROKS cluster id. Use the ROKS terraform module or other way to create it"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  description = "Region of the cluster"
}

variable "resource_group_name" {
  description = "Resource group that the cluster is created in"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "accept_cpd_license" {
  type        = bool
  description = "Do you accept the cpd license agreements? This includes any modules chosen as well. `true` or `false`"
}

// Prereq
variable "worker_node_flavor" {
  type        = string
  description = "Flavor used to determine worker node hardware"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

// Modules available to install on CP4D

# variable "bedrock_zen_operator" {
#   default = false
#   type = string
#   description = "Install Bedrock Zen Operator. Only for Cloud Pak for Data v4.0"
@ }

variable "install_ccs" {
  default = false
  type = string
  description = "Install CCS module. Only for Cloud Pak for Data v4.0"
}

variable "install_data_refinery" {
  default = false
  type = string
  description = "Install Data Refinery module. Only for Cloud Pak for Data v4.0"
}

variable "install_db2u_operator" {
  default = false
  type = string
  description = "Install DB2U Operator. Only for Cloud Pak for Data v4.0"
}

variable "install_dmc" {
  default = false
  type = string
  description = "Install DMC module. Only for Cloud Pak for Data v4.0"
}

variable "install_db2aaservice" {
  default = false
  type = string
  description = "Install DB2aaService module. Only for Cloud Pak for Data v4.0"
}

variable "install_wsl" {
  default = false
  type = string
  description = "Install WSL module. Only for Cloud Pak for Data v4.0"
}

variable "install_aiopenscale" {
  default = false
  type = string
  description = "Install AI Open Scale module. Only for Cloud Pak for Data v4.0"
}

variable "install_wml" {
  default = false
  type = string
  description = "Install Watson Machine Learning module. Only for Cloud Pak for Data v4.0"
}

variable "install_wkc" {
  default = false
  type = string
  description = "Install Watson Knowledge Catalog module. Only for Cloud Pak for Data v4.0"
}

variable "install_dv" {
  default = false
  type = string
  description = "Install Data Virtualization module. Only for Cloud Pak for Data v4.0"
}

variable "install_spss" {
  default = false
  type = string
  description = "Install SPSS module. Only for Cloud Pak for Data v4.0"
}

variable "install_cde" {
  default = false
  type = string
  description = "Install CDE module. Only for Cloud Pak for Data v4.0"
}

variable "install_spark" {
  default = false
  type = string
  description = "Install Analytics Engine powered by Apache Spark module. Only for Cloud Pak for Data v4.0"
}

variable "install_dods" {
  default = false
  type = string
  description = "Install DODS module. Only for Cloud Pak for Data v4.0"
}

variable "install_ca" {
  default = false
  type = string
  description = "Install CA module. Only for Cloud Pak for Data v4.0"
}

variable "install_ds" {
  default = false
  type = string
  description = "Install DS module. Only for Cloud Pak for Data v4.0"
}

variable "install_db2oltp" {
  default = false
  type = string
  description = "Install DB2OLTP module. Only for Cloud Pak for Data v4.0"
}

variable "install_db2wh" {
  default = false
  type = string
  description = "Install DB2WH module. Only for Cloud Pak for Data v4.0"
}

variable "install_big_sql" {
  default = false
  type = string
  description = "Install Big SQL module. Only for Cloud Pak for Data v4.0"
}

locals {
  cluster_config_path = "./.kube/config"
}
