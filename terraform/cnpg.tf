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
  results = toset(split("---", data.http.cnpg_yaml_raw.response_body))

  all_ips = [
    "10.0.1.5",
    "10.0.1.6",
    "10.0.2.5",
    "10.0.1.5", # Duplicate
  ]

}

// data "http" "cnpg_operator_yaml" {
//   url = local.cnpg_manifest_url
// }

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

data "http" "cnpg_yaml_raw" {
  url = local.cnpg_manifest_url
}

data "kubectl_file_documents" "cnpg_multi_doc" {
  content = data.http.cnpg_yaml_raw.response_body
}


resource "kubectl_manifest" "cnpg_east" {
  provider  = kubectl.kubectl-east
  for_each  = data.kubectl_file_documents.cnpg_multi_doc.manifests
  yaml_body = each.value
  server_side_apply = true
}


resource "kubectl_manifest" "cnpg_west" {
  provider  = kubectl.kubectl-west
  for_each  = data.kubectl_file_documents.cnpg_multi_doc.manifests
  yaml_body = each.value
  server_side_apply = true
}