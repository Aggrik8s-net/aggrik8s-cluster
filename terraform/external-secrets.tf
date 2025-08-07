//     We need to follow this guide.
//     https://www.talos.dev/v1.10/kubernetes-guides/configuration/ceph-with-rook/
//
//     IMPORTANT:    WIPE Rook DISK befoe running this or not so good.
//
// 1.  - Install our HELM Repo
//       $ helm repo add rook-release https://charts.rook.io/release

//
//
// helm repo add external-secrets https://charts.external-secrets.io
//
//   helm install external-secrets \
//      external-secrets/external-secrets \
//       -n external-secrets \
//       --create-namespace \
//     # --set installCRDs=false
//
//

// 2.  - Label our namespace to ??? <allow metrics-server on Nodes>` ???.
//       kubectl label namespace rook-ceph pod-security.kubernetes.io/enforce=privileged
//           ? is the namespace created yet ?

// 3.  - Profit.
//       helm install --create-namespace --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster

/*

helm repo add kubescape https://kubescape.github.io/helm-charts/ ; helm repo update ; helm upgrade --install kubescape kubescape/kubescape-operator -n kubescape --create-namespace --set clusterName=`kubectl config current-context` --set capabilities.continuousScan=enable


*/


resource "kubernetes_namespace" "external-secrets-east" {
  depends_on  =  [doppler_secret.kubeconfig-server-east,
                  doppler_secret.client_certificate_east,
                  doppler_secret.client_key_east,
                  doppler_secret.cluster_ca_certificate_east]
  metadata {
    name   = "external-secrets"
    labels = {
               "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
  provider = kubernetes.talos-proxmox-east
}

resource "kubernetes_namespace" "external-secrets-west" {
  depends_on  =  [doppler_secret.kubeconfig-server-west,
                  doppler_secret.client_certificate_west,
                  doppler_secret.client_key_west,
                  doppler_secret.cluster_ca_certificate_west]
  metadata {
    name   = "external-secrets"
    labels = {
               "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
  provider = kubernetes.talos-proxmox-west
}


resource "helm_release" "external-secrets-east" {
  depends_on = [kubernetes_namespace.external-secrets-east,
                doppler_secret.kubeconfig_east,
                doppler_secret.kubeconfig-server-east,
                doppler_secret.client_certificate_east,
                doppler_secret.client_key_east,
                doppler_secret.cluster_ca_certificate_east]

  description = "HELM Chart to install the External Secrets operator."
  provider = helm.helm-east
  name  = "external-secrets"
  chart = "external-secrets"
  repository = "https://charts.external-secrets.io"
  namespace = "external-secrets"

  // set = [
  //     {
  //       name  = "clusterName"
  //       value = "talos-east"
  //     },
  //     {
  //       name  = "capabilities.continuousScan"
  //       value = "enable"
  //     }
  // ]
}

resource "helm_release" "external-secrets-west" {
  depends_on = [kubernetes_namespace.external-secrets-west,
                doppler_secret.kubeconfig_west,
                doppler_secret.kubeconfig-server-west,
                doppler_secret.client_certificate_west,
                doppler_secret.client_key_west,
                doppler_secret.cluster_ca_certificate_west]

  description = "HELM Chart to install the External Secrets operator."
  provider = helm.helm-west
  name  = "external-secrets"
  chart = "external-secrets"
  repository = "https://charts.external-secrets.io"
  namespace = "external-secrets"

  // set = [
  //      {
  //        name  = "clusterName"
  //        value = "talos-west"
  //      },
  //      {
  //        name  = "capabilities.continuousScan"
  //        value = "enable"
  //      }
  //  ]
}