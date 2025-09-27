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
}

data "http" "cnpg_operator_yaml" {
  url = local.cnpg_manifest_url
}

resource "kubernetes_manifest" "cnpg_operator_crd" {
  for_each = toset(split("---", data.http.cnpg_operator_yaml.response_body))
  yaml_body = each.value
}
