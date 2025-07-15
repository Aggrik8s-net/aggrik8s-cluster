//
// Refer to https://www.talos.dev/v1.10/kubernetes-guides/network/deploying-cilium/
// And      https://registry.terraform.io/providers/littlejo/cilium/latest/docs
//

// data "kubectl_filename_list" "manifests" {
//   pattern = "~/Talos/*.yaml"
// }
// resource "kubectl_manifest" "test" {
//  count     = length(data.kubectl_filename_list.manifests.matches)
//  yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
// }

/*
        First we install gateway-api CRD's in both clusters.
*/

// #1 - gateway.networking.k8s.io_gatewayclasses.yaml
data "http" "manifest_cert-approver" {
  url = "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
}
data "kubectl_path_documents" "cert-approver-docs" {
  pattern  = data.http.manifest_cert-approver.response_body
}
output "kubectl_path_documents_cert-approver-docs" {
  value = data.kubectl_path_documents.cert-approver-docs
  sensitive = true
}
output "kubectl_path_documents_cert-approver-docs_pattern" {
  value = data.kubectl_path_documents.cert-approver-docs.pattern
  sensitive = true
}


resource "kubectl_manifest" "cert-approver-east" {
  provider = kubectl.kubectl-east
  // yaml_body = data.kubectl_path_documents.cert-approver-docs.pattern
  yaml_body = data.kubectl_path_documents.cert-approver-docs.pattern

}
resource "kubectl_manifest" "cert-approver-west" {
  provider = kubectl.kubectl-west
  // yaml_body = data.kubectl_path_documents.cert-approver-docs.pattern
  yaml_body = data.kubectl_path_documents.cert-approver-docs.pattern
}
output "kubectl_path_documents-cert-approver_element-count" {
  value =  length(data.kubectl_path_documents.metrics-server-docs)
}
output "kubectl_path_documents-cert-approver_elements" {
  value = {
    for k, doc in data.kubectl_path_documents.cert-approver-docs : k => doc
  }
  sensitive = true
}
output "kubectl_path_documents-cert-approver_manifests" {
  value = {
    for k, manifest in data.kubectl_path_documents.metrics-server-docs.manifests : k => manifest
  }
  // sensitive = true
}



// #2 - metrics-server manifest
data "http" "manifest_metrics-server" {
  url = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
}
data "kubectl_path_documents" "metrics-server-docs" {
  pattern = data.http.manifest_metrics-server.response_body
}

resource "kubectl_manifest" "metrics-server-east" {
  provider = kubectl.kubectl-east
  yaml_body = data.kubectl_path_documents.metrics-server-docs.pattern
  // for_each = data.kubectl_path_documents.metrics-server-docs.pattern
  // yaml_body = each.value
}

resource "kubectl_manifest" "metrics-server-west" {
  provider = kubectl.kubectl-west
  yaml_body = data.kubectl_path_documents.metrics-server-docs.pattern
  // for_each = data.kubectl_path_documents.metrics-server-docs.pattern
  // yaml_body = each.value
}

output "kubectl_path_documents-metrics-server_element-count" {
  value =  length(data.kubectl_path_documents.cert-approver-docs)
}
output "kubectl_path_documents-metrics-server_elements" {
  value = {
    for k, doc in data.kubectl_path_documents.metrics-server-docs : k => doc
  }
  sensitive = true
}

output "kubectl_manifest_metrics-server-pattern" {
  description = "Errach YAML docuemnt in metrics-server document."
  value = data.kubectl_path_documents.metrics-server-docs.pattern
  // value = {
  //   for k, pattern in data.kubectl_path_documents.metrics-server-docs.pattern : k => pattern
  // }
}



// output "kubectl_path_documents-metrics-server_parsed" {
//   value = {
//     for k, doc in yamldecode(data.kubectl_path_documents.metrics-server-docs.pattern) : k => doc
//   }
//   sensitive = true
// }


/*
        Next we  install Cilium in both clusters.
*/
