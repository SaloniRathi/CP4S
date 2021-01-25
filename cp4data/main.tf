locals {
  storage_class_file = {
    "ibmc-file-custom-gold-gid" = join("/", [path.module, "files", "sc_ibmc_file_custom_gold_gid.yaml"])
    "portworx-shared-gp3"       = ""
  }
  storage_class_content = file(local.storage_class_file[var.storage_class_name])

  security_context_constraints_content = templatefile("${path.module}/templates/security_context_constraints.tmpl.yaml", {
    namespace = local.namespace,
  })

  installer_sensitive_data = templatefile("${path.module}/templates/installer_sensitive_data.tmpl.yaml", {
    namespace                        = local.namespace,
    docker_username_encoded          = base64encode(local.docker_username),
    docker_registry_password_encoded = base64encode(local.entitled_registry_key),
  })

  installer_job_content = templatefile("${path.module}/templates/installer_job.tmpl.yaml", {
    namespace          = local.namespace,
    storage_class_name = var.storage_class_name,
    docker_registry    = local.docker_registry,

    // Modules to deploy
    install_watson_knowledge_catalog = var.install_watson_knowledge_catalog, // WKC
    install_watson_studio            = var.install_watson_studio,            // WSL
    install_watson_machine_learning  = var.install_watson_machine_learning,  // WML
    install_watson_open_scale        = var.install_watson_open_scale,        // AIOPENSCALE
    install_data_virtualization      = var.install_data_virtualization,      // DV
    install_streams                  = var.install_streams,                  // STREAMS
    install_analytics_dashboard      = var.install_analytics_dashboard,      // CDE
    install_spark                    = var.install_spark,                    // SPARK
    install_db2_warehouse            = var.install_db2_warehouse,            // DB2WH
    install_db2_data_gate            = var.install_db2_data_gate,            // DATAGATE
    install_rstudio                  = var.install_rstudio,                  // RSTUDIO
    install_db2_data_management      = var.install_db2_data_management,      // DMC
  })
}

resource "null_resource" "install_cp4data" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                              = var.force ? timestamp() : 0
    namespace_sha1                            = sha1(local.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    storage_class_content_sha1                = sha1(local.storage_class_content)
    security_context_constraints_content_sha1 = sha1(local.security_context_constraints_content)
    installer_sensitive_data_sha1             = sha1(local.installer_sensitive_data)
    installer_job_content_sha1                = sha1(local.installer_job_content)
  }

  provisioner "local-exec" {
    command     = "./install_cp4data.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                    = var.force
      KUBECONFIG               = var.cluster_config_path
      NAMESPACE                = local.namespace
      STORAGE_CLASS_NAME       = var.storage_class_name
      DOCKER_REGISTRY_PASS     = local.entitled_registry_key
      DOCKER_USER_EMAIL        = var.entitled_registry_user_email
      DOCKER_USERNAME          = local.docker_username
      DOCKER_REGISTRY          = local.docker_registry
      STORAGE_CLASS_CONTENT    = local.storage_class_content
      INSTALLER_SENSITIVE_DATA = local.installer_sensitive_data
      INSTALLER_JOB_CONTENT    = local.installer_job_content
      SCC_ZENUID_CONTENT       = local.security_context_constraints_content
    }
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4data,
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = local.namespace
  }
}

// TODO: It may be considered in a future version to pass the cluster ID and the
// resource group to get the cluster configuration and store it in memory and in
// a directory, either specified by the user or in the module local directory

// variable "resource_group" {
//   default     = "default"
//   description = "List all available resource groups with: ibmcloud resource groups"
// }
// data "ibm_resource_group" "group" {
//   name = var.resource_group
// }
// data "ibm_container_cluster_config" "cluster_config" {
//   cluster_name_id   = var.cluster_id
//   resource_group_id = data.ibm_resource_group.group.id
// }
