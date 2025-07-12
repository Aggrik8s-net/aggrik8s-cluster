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
      configuration_aliases = [kubernetes.kubeconfig-east, kubernetes.kubeconfig-west]
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
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

provider "kubernetes" {
  alias          = "kubeconfig-east"
  config_path    = "${path.module}/tmp/kubeconfig-east"
  config_context = "my-context"
}

provider "kubernetes" {
    alias = "kubeconfig-west"
    config_path    = "${path.module}/tmp/kubeconfig-west"
    config_context = "my-context"
}