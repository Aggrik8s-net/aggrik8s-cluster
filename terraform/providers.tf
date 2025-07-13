terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.75.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7.1"
    }
    cilium = {
      source  = "littlejo/cilium"
      version = "~> 0.3.1"
      configuration_aliases = [ cilium.cilium-east, cilium.cilium-west ]
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      configuration_aliases = [ # kubernetes.kubeconfig-east,
                                # kubernetes.kubeconfig-west,
                               kubernetes.talos-proxmox-east,
                               kubernetes.talos-proxmox-west]
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
      configuration_aliases = [helm.helm-east, helm.helm-west]
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.19.0"
      configuration_aliases = [kubectl.kubectl-east, kubectl.kubectl-west]
    }
  }
}

provider "proxmox" {
  endpoint   = "https://192.168.10.10:8006"
  api_token  =  "terraform@pam!terraform-api-key=8f4973ee-e3e4-4897-97f0-d11313bad16a"
  insecure   = true
  ssh {
    agent    = true
    username = "root"
    password = "myPr0xM0x"
  }
}

provider "cilium" {
# Configuration options
config_path = "${path.module}/kubeconfig-east"
alias = "cilium-east"
}

provider "cilium" {
# Configuration options
config_path = "${path.module}/kubeconfig-west"
alias = "cilium-west"
}

// provider "kubernetes" {
//   alias          = "kubeconfig-east"
//   config_path    = "${path.module}/tmp/kubeconfig-east"
//   config_context = "talos-east"
// }

// provider "kubernetes" {
//     alias = "kubeconfig-west"
//     config_path    = "${path.module}/tmp/kubeconfig-west"
//     config_context = "talos-=west"
// }

provider "kubectl" {
  alias          = "kubectl-east"
  // host           =  var.east_host
  config_path    = "${path.module}/tmp/kubeconfig-east"
  // config_context = "admin@talos-east"
  // client_certificate     = base64decode(var.east_client_certificate)
  // client_key             = base64decode(var.east_client_key)
  // cluster_ca_certificate = base64decode(var.east_cluster_ca_certificate)
}

provider "kubectl" {
  alias = "kubectl-west"
  // host = var.west_host
  config_path    = "${path.module}/tmp/kubeconfig-west"
  // config_context = "admin@talos-west"
  // client_certificate     = base64decode(var.west_client_certificate)
  // client_key             = base64decode(var.west_client_key)
  // cluster_ca_certificate = base64decode(var.west_cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "talos-proxmox-east"
  host = var.east_host

  client_certificate     = base64decode(var.east_client_certificate)
  client_key             = base64decode(var.east_client_key)
  cluster_ca_certificate = base64decode(var.east_cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "talos-proxmox-west"
  host = var.west_host

  client_certificate     = base64decode(var.west_client_certificate)
  client_key             = base64decode(var.west_client_key)
  cluster_ca_certificate = base64decode(var.west_cluster_ca_certificate)
}

provider "helm" {
  alias = "helm-east"
  kubernetes = {
    config_path = "${path.module}/tmp/kubeconfig-east"
  }
}

provider "helm" {
  alias = "helm-west"
  kubernetes = {
    config_path = "${path.module}/tmp/kubeconfig-west"
  }

}