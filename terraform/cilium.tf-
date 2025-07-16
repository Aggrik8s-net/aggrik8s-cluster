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

resource "kubernetes_namespace" "cilium-test-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider    =  kubernetes.talos-proxmox-east
  metadata {
    name   = "cilium-test-1"
    labels    = {
                  "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_namespace" "cilium-test-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider    =  kubernetes.talos-proxmox-west
  metadata {
    name   = "cilium-test-1"
    labels    = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

data "http" "manifest_gateway-api_gatewayclasses" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml"
}
resource "kubectl_manifest" "gateway-api_gatewayclasses-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider = kubectl.kubectl-east
  yaml_body = data.http.manifest_gateway-api_gatewayclasses.response_body
}
resource "kubectl_manifest" "gateway-api_gatewayclasses-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider = kubectl.kubectl-west
  yaml_body = data.http.manifest_gateway-api_gatewayclasses.response_body
}
// #2 - gateway.networking.k8s.io_gateways.yaml
data "http" "manifest_gateway-api_gateways" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml"
}
resource "kubectl_manifest" "gateway-api_gateways-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider = kubectl.kubectl-east
  yaml_body = data.http.manifest_gateway-api_gateways.response_body
}
resource "kubectl_manifest" "gateway-api_gateways-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider = kubectl.kubectl-west
  yaml_body = data.http.manifest_gateway-api_gateways.response_body
}
// #3 - gateway.networking.k8s.io_httproutes.yaml"
data "http" "manifest_gateway-api_httproutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml"
}
resource "kubectl_manifest" "gateway-api_httproutes-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider = kubectl.kubectl-east
  yaml_body = data.http.manifest_gateway-api_httproutes.response_body
}
resource "kubectl_manifest" "gateway-api_httproutes-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider = kubectl.kubectl-west
  yaml_body = data.http.manifest_gateway-api_httproutes.response_body
}
// #4 - gateway.networking.k8s.io_referencegrants.yaml
data "http" "manifest_gateway-api_referencegrants" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml"
}
resource "kubectl_manifest" "gateway-api_referencegrants-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider = kubectl.kubectl-east
  yaml_body = data.http.manifest_gateway-api_referencegrants.response_body
}
resource "kubectl_manifest" "gateway-api_referencegrants-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider = kubectl.kubectl-west
  yaml_body = data.http.manifest_gateway-api_referencegrants.response_body
}
// #5 - gateway.networking.k8s.io_grpcroutes.yaml
data "http" "manifest_gateway-api_grpcroutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml"
}
resource "kubectl_manifest" "gateway-api_grpcroutes-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider = kubectl.kubectl-east
  yaml_body = data.http.manifest_gateway-api_grpcroutes.response_body
}
resource "kubectl_manifest" "gateway-api_grpcroutes-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider = kubectl.kubectl-west
  yaml_body = data.http.manifest_gateway-api_grpcroutes.response_body
}
// #6 - gateway.networking.k8s.io_tlsroutes.yaml
data "http" "manifest_gateway-api_tlsroutes" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
}
resource "kubectl_manifest" "gateway-api_tlsroutes-east" {
  depends_on  =  [module.talos-proxmox-east, local_file.kubeconfig-east]
  provider = kubectl.kubectl-east
  yaml_body = data.http.manifest_gateway-api_tlsroutes.response_body
}
resource "kubectl_manifest" "gateway-api_tlsroutes-west" {
  depends_on  =  [module.talos-proxmox-west, local_file.kubeconfig-west]
  provider = kubectl.kubectl-west
  yaml_body = data.http.manifest_gateway-api_tlsroutes.response_body
}

/*
        Next we  install Cilium in both clusters.
*/


// resource "kubernetes" "" {}


// $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
// resource "kubernetes_  " "cilium" {}
// $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
// $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
// $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
// $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
// $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml

/*

    Use HELM to install Cilium with ApiGteway support.

helm install \
cilium \
cilium/cilium \
--version 1.15.6 \
--namespace kube-system \
--set ipam.mode=kubernetes \
--set kubeProxyReplacement=true \
--set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
--set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
--set cgroup.autoMount.enabled=false \
--set cgroup.hostRoot=/sys/fs/cgroup \
--set k8sServiceHost=localhost \
--set k8sServicePort=7445
--set=gatewayAPI.enabled=true \
--set=gatewayAPI.enableAlpn=true \
--set=gatewayAPI.enableAppProtocol=true

*/
/*
resource "cilium" "talos-proxmox-east" {
  depends_on = [module.talos-proxmox-east]
  set = [
    "ipam.mode=kubernetes",
    "kubeProxyReplacement=true",
    "securityContext.capabilities.ciliumAgent={CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}`",
    "securityContext.capabilities.cleanCiliumState = '{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}'",
    "cgroup.autoMount.enabled=false",
    "cgroup.hostRoot=/sys/fs/cgroup",
    "k8sServiceHost=localhost",
    "k8sServicePort=7445",
    "gatewayAPI.enabled=true",
    "gatewayAPI.enableAlpn=true",
    "gatewayAPI.enableAppProtocol=true"
  ]
  version = "1.14.5"
}

resource "cilium" "talos-proxmox-west" {
  depends_on = [module.talos-proxmox-west]
  set = [
    "ipam.mode=kubernetes",
    "kubeProxyReplacement=true",
    "securityContext.capabilities.ciliumAgent = \"{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}\"",
    "securityContext.capabilities.cleanCiliumState = \"{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}\"",
    "cgroup.autoMount.enabled=false",
    "cgroup.hostRoot=/sys/fs/cgroup",
    "k8sServiceHost=localhost",
    "k8sServicePort=7445",
    "gatewayAPI.enabled=true",
    "gatewayAPI.enableAlpn=true",
    "gatewayAPI.enableAppProtocol=true"
  ]
  version = "1.14.5"
}
*/