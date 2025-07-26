//     We need to follow this guide.
//     https://www.talos.dev/v1.10/kubernetes-guides/configuration/ceph-with-rook/
//
//     IMPORTANT:    WIPE Rook DISK befoe running this or not so good.
//
// 1.  - Install our HELM Repo
//       $ helm repo add rook-release https://charts.rook.io/release



// 2.  - Label our namespace to ??? <allow metrics-server on Nodes>` ???.
//       kubectl label namespace rook-ceph pod-security.kubernetes.io/enforce=privileged
//           ? is the namespace created yet ?

// 3.  - Profit.
//       helm install --create-namespace --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster


resource "kubernetes_namespace" "rook-ceph-east" {
  depends_on  =  [module.talos-proxmox-east.kubeconfig]
  metadata {
    name   = "rook-ceph"
    labels = {
               "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
  provider = kubernetes.talos-proxmox-east
}

resource "kubernetes_namespace" "rook-ceph-west" {
  depends_on  =  [module.talos-proxmox-west.kubeconfig]
  metadata {
    name   = "rook-ceph"
    labels = {
               "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
  provider = kubernetes.talos-proxmox-west
}

// resource "talos-wipe-disk" "wipe-disks-east"{
//   depends_on  =  [talosconfig-east]
// }
// resource "talos-wipe-disk" "wipe-disks-west"{
//   depends_on  =  [talosconfig-west]
// }


resource "helm_release" "rook-operator-east" {
  depends_on = [kubernetes_namespace.rook-ceph-east,
                doppler_secret.kubeconfig_east]

  description = "HELM Chart to install the rook-operator."
  provider = helm.helm-east
  name  = "rook-ceph"
  chart = "rook-ceph"
  repository = "https://charts.rook.io/release"
  namespace = "rook-ceph"
}

resource "helm_release" "rook-operator-west" {
  depends_on = [kubernetes_namespace.rook-ceph-west,
                doppler_secret.kubeconfig_west]
  description = "HELM Chart to install the rook-operator."
  provider = helm.helm-west
  name  = "rook-ceph"
  chart = "rook-ceph"
  repository = "https://charts.rook.io/release"
  namespace = "rook-ceph"
}

resource "helm_release" "rook-ceph-cluster-east" {
  depends_on = [kubernetes_namespace.rook-ceph-east,
                helm_release.rook-operator-east]
  description = "HELM Chart to install the rook-ceph cluster."
  provider = helm.helm-east
  name  = "rook-ceph-cluster"
  chart = "rook-ceph-cluster"
  repository = "https://charts.rook.io/release"
  namespace = "rook-ceph"
}

resource "helm_release" "rook-ceph-cluster-west" {
  depends_on = [kubernetes_namespace.rook-ceph-west,
                helm_release.rook-operator-west]
  description = "HELM Chart to install the rook-ceph cluster."
  provider = helm.helm-west
  name  = "rook-ceph-cluster"
  chart = "rook-ceph-cluster"
  repository = "https://charts.rook.io/release"
  namespace = "rook-ceph"
}

