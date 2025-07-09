#terraform {
#    required_providers {
#        proxmox = {
#            source = "telmate/proxmox"
#            version = "3.0.2-rc01"
#        }
#    }
#}


terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.75.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "~> 0.7.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    cilium = {
      source = "littlejo/cilium"
      version = "0.3.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.1"
    }
  }
}

provider "proxmox" {
  endpoint   = var.virtual_environment_endpoint
  api_token  =  "terraform@pam!terraform-api-key=8f4973ee-e3e4-4897-97f0-d11313bad16a"
  insecure   = true
  ssh {
    agent    = true
    username = "root"
    password = "myPr0xM0x"
  }
}

provider "kubernetes" {
  # Just use the kubeconfig
  config_path = "~/Talos/kubeconfig"

  # host = var.host
  # client_certificate     = base64decode(data.talos_cluster_kubeconfig.kubeconfig.client_configuration.client_certificate)
  # client_key             = base64decode(data.talos_cluster_kubeconfig.kubeconfig.client_configuration.client_key)
  # cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate)
}

provider "cilium" {
  config_path = "${path.module}/kubeconfig"
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/kubeconfig"
  }

#`  registries = [
#    {
#      url      = "oci://localhost:5000"
#      username = "username"
#      password = "password"
#    },
#    {
#      url      = "oci://private.registry"
#      username = "username"
#      password = "password"
#    }
#  ]
}
