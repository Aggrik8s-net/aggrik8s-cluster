//
//     CNPG  -  Install Operator and initial cluster
//

// Split the following multi-doc YAML
// https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.0.yaml
locals {
  // cnpg_operator_manifest_path = "path/to/cnpg-operator.yaml" # Replace with your CNPG YAML path
  // raw_cnpg_manifests = split("---\n", file(local.cnpg_operator_manifest_path))
  // hcl_cnpg_manifests = [for manifest in local.raw_cnpg_manifests : yamldecode(manifest)]
  cnpg_manifest_url  = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.0.yaml"
  // results = toset(split("---", data.http.cnpg_yaml_raw.response_body))
  cnpg_crd_manifest = provider::kubernetes::manifest_decode_multi(data.http.cnpg_operator_yaml.response_body)

  all_ips = [
    "10.0.1.5",
    "10.0.1.6",
    "10.0.2.5",
    "10.0.1.5", # Duplicate
  ]
}

// output "cnpg_crd_manifest" {
//   value = local.cnpg_crd_manifest
// }

data "http" "cnpg_operator_yaml" {
  url = local.cnpg_manifest_url
}

// resource "kubernetes_manifest" "cnpg_operator_crd" {
//   for_each = toset(split("---", data.http.cnpg_operator_yaml.response_body))
//   # yaml_body = each.value
//   manifest  = each.value
// }

// output "results" {
//   value =toset(split("---", data.http.cnpg_operator_yaml.response_body))
// }

// output "unique_ips" {
//   value       = toset(local.all_ips)
//   description = "A set containing all unique IP addresses."
// }

// data "http" "cnpg_yaml_raw" {
//   url = local.cnpg_manifest_url
// }

// data "kubectl_file_documents" "cnpg_multi_doc" {
//   content = data.http.cnpg_yaml_raw.response_body
// }

data "http" "cnpg_operator_multidoc_yaml" {
  url = local.cnpg_manifest_url
}

data "kubectl_path_documents" "cnpg_crd_manifests" {
  pattern = data.http.cnpg_operator_multidoc_yaml.response_body
}

/*
resource "kubernetes_manifest" "cnpg_operator_crd" {
  provider = kubernetes.talos-proxmox-east
  // for_each = toset(split("---", data.http.cnpg_operator_multidoc_yaml.response_body))
  // for_each =  local.cnpg_crd_manifest
  for_each = {
    for i in provider::kubernetes::manifest_decode_multi(data.http.cnpg_operator_yaml.response_body) : "${i.kind}-${i.metadata.name}" => i
  }
//  manifest = each.value
  // for_each = toset(local.cnpg_crd_manifest)

  manifest = each.value
  // yaaml_body = yamldecode(each.value)
  // yaml_body = each.value
}

// not supported AI halucination
// data "kubernetes_manifest_decode_multi" "decoded_cnpg_manifests" {
//   content = data.http.cnpg_operator_yaml
// }
*/

/*
resource "kubernetes_namespace" "cnpg-system-east" {
  provider = kubernetes.talos-proxmox-east
  depends_on = [module.talos-proxmox-east.kubeconfig]
  metadata {
    name = "cnpg-system"
    // labels = {
    //   "pod-security.kubernetes.io/enforce" = "privileged"
    // }
  }
}
*/

resource "kubernetes_manifest" "cnpg_east" {
  provider  = kubernetes.talos-proxmox-east
  for_each = {
    for i in provider::kubernetes::manifest_decode_multi(data.http.cnpg_operator_yaml.response_body) : "${i.kind}-${i.metadata.name}-${lookup(i.metadata, "namespace","default")}" => i
  }
  manifest = each.value
}

/*
resource "kubernetes_namespace" "cnpg-system-west" {
  provider = kubernetes.talos-proxmox-west
  depends_on = [module.talos-proxmox-west.kubeconfig]
  metadata {
    name = "cnpg-system"
    // labels = {
    //   "pod-security.kubernetes.io/enforce" = "privileged"
    // }
  }
}
*/

//resource "kubectl_manifest" "cnpg_west" {
resource "kubernetes_manifest" "cnpg_west" {
  provider  = kubernetes.talos-proxmox-west
  for_each = {
    for i in provider::kubernetes::manifest_decode_multi(data.http.cnpg_operator_yaml.response_body)  : "${i.kind}_${i.metadata.name}_${lookup(i.metadata, "namespace","default")}" => i
  }
  manifest = each.value
}

/*
resource "kubernetes_manifest" "cnpg_db_east" {
  provider  = kubernetes.talos-proxmox-east
  depends_on = [kubernetes_manifest.cnpg_east]
  for_each = {
    for i in provider::kubernetes::manifest_decode_multi(file("${path.root}/../database/cnpg_test_cluster.yaml"))  : "${i.kind}_${i.metadata.name}_${lookup(i.metadata, "namespace","default")}" => i
  }
  manifest = each.value
}

resource "kubernetes_manifest" "cnpg_db_west" {
  provider  = kubernetes.talos-proxmox-west
  depends_on = [kubernetes_manifest.cnpg_west]
  for_each = {
    for i in provider::kubernetes::manifest_decode_multi(file("${path.root}/../database/cnpg_test_cluster.yaml"))  : "${i.kind}_${i.metadata.name}_${lookup(i.metadata, "namespace","default")}" => i
  }
  manifest = each.value
}
*/

