//
// Refer to https://www.talos.dev/v1.10/kubernetes-guides/network/deploying-cilium/
// And      https://registry.terraform.io/providers/littlejo/cilium/latest/docs
//

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