// provider "kubernetes" {
//   config_path = var.enable ? var.cluster_config_path : null
// }

// resource "kubernetes_namespace" "mcm_namespace" {
//   count = var.enable ? 1 : 0

//   metadata {
//     name = local.mcm_namespace
//   }

//   timeouts {
//     delete = "2h"
//   }
// }

locals {
  catalogsource_content = templatefile("${path.module}/templates/CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number,
  })
  installation_content = templatefile("${path.module}/templates/Installation.yaml.tmpl", {
    namespace                    = local.mcm_namespace,
    install_infr_mgt_module      = var.install_infr_mgt_module,
    install_monitoring_module    = var.install_monitoring_module,
    install_security_svcs_module = var.install_security_svcs_module,
    install_operations_module    = var.install_operations_module,
    install_tech_prev_module     = var.install_tech_prev_module
  })
  subscription_file    = "${path.module}/files/Subscription.yaml"
  subscription_content = file(local.subscription_file)
}

resource "null_resource" "install_cp4mcm" {
  count = var.enable ? 1 : 0

  // depends_on = [
  //   kubernetes_namespace.mcm_namespace,
  // ]
  triggers = {
    docker_credentials_sha1 = sha1(join("", [local.entitled_registry_user, var.entitled_registry_key, var.entitled_registry_user_email, local.entitled_registry, local.mcm_namespace]))
    catalogsource_sha1      = sha1(local.catalogsource_content)
    subscription_sha1       = sha1(local.subscription_content)
    installation_sha1       = sha1(local.installation_content)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_cp4mcm.sh"

    environment = {
      KUBECONFIG                       = var.cluster_config_path
      MCM_NAMESPACE                    = local.mcm_namespace
      MCM_ENTITLED_REGISTRY_USER       = local.entitled_registry_user
      MCM_ENTITLED_REGISTRY_KEY        = local.entitled_registry_key
      MCM_ENTITLED_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      MCM_ENTITLED_REGISTRY            = local.entitled_registry
      MCM_CATALOGSOURCE_CONTENT        = local.catalogsource_content
      MCM_INSTALLATION_CONTENT         = local.installation_content
      MCM_SUBSCRIPTION_FILE            = local.subscription_file
      MCM_WAIT_SEC                     = 30
    }
  }
}

// data "kubernetes_secret" "mcm_credentials" {
//   count = var.enable ? 1 : 0

//   depends_on = [
//     null_resource.install_cp4mcm,
//   ]

//   metadata {
//     name      = "platform-auth-idp-credentials"
//     namespace = "ibm-common-services"
//   }
// }

data "external" "kubectl_get_mcm_admin_username" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4mcm,
  ]

  program = ["sh", "-c", "echo \"{ \\\"username\\\": \\\"$(kubectl --kubeconfig ${var.cluster_config_path} get secret platform-auth-idp-credentials -n ibm-common-services -o jsonpath='{.data.admin_username}')\\\" }\""]
}

data "external" "kubectl_get_mcm_admin_password" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4mcm,
  ]

  program = ["sh", "-c", "echo \"{ \\\"password\\\": \\\"$(kubectl --kubeconfig ${var.cluster_config_path} get secret platform-auth-idp-credentials -n ibm-common-services -o jsonpath='{.data.admin_password}')\\\" }\""]
}

data "external" "kubectl_get_endpoint" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4mcm,
  ]

  program = ["sh", "-c", "echo \"{ \\\"host\\\": \\\"$(kubectl --kubeconfig ${var.cluster_config_path} get route cp-console -n ibm-common-services -o jsonpath='{.spec.host}')\\\" }\""]
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
