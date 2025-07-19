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
    // kubectl = {
    //   source = "gavinbunney/kubectl"
    //   version = "1.19.0"
    //   configuration_aliases = [kubectl.kubectl-east, kubectl.kubectl-west]
    // }
    kubectl = {
      source = "alekc/kubectl"
      version = "2.1.3"
    }
    doppler = {
      source = "DopplerHQ/doppler"
    }
  }
}

provider "proxmox" {
  endpoint   = var.proxmox_api_endpoint
  // api_token  =  var.proxmox_api_token
  api_token  =  data.doppler_secrets.this.map.proxmox_api_token
  insecure   = true
  ssh {
    agent    = true
    // username = var.proxmox_user
    username = data.doppler_secrets.this.map.proxmox_user
    // password = var.proxmox_root_pwd
    password = data.doppler_secrets.this.map.root_pwd
  }
}

provider "cilium" {
  # Configuration options
  // config_path = "${path.module}/kubeconfig-east"
  // config_path = "${path.module}/kubeconfig"
  // config_context = "admin@talos-east"
  // alias = "cilium-east"
  host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])
}

provider "cilium" {
  # Configuration options
  // config_path = "${path.module}/kubeconfig"
  // config_context = "admin@talos-west"
  alias = "cilium-west"
  host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["certificate-authority-data"])

}

provider "kubectl" {
  alias          = "kubectl-east"
  // config_path    = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-east"
  host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])
}

provider "kubectl" {
  alias          = "kubectl-west"
  // config_path    = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-west"
  host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["certificate-authority-data"])
}

provider "kubernetes" {
  alias = "talos-proxmox-east"

  host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])

  // config_path    = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-east"
  // config_path = module.talos-proxmox-east.kubeconfig

}

/*
output "kube_secret_client-certificate-data" {
    value = nonsensitive(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"])
}
output "kube_secret_cluster_ca_data" {
    value = nonsensitive(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])
}
output "kube_secret_cluster_server" {
    value = nonsensitive(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"])
}
*/


provider "kubernetes" {
  alias = "talos-proxmox-west"

  host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["certificate-authority-data"])

  // config_path = module.talos-proxmox-west.kubeconfig
  // config_path = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-west"

}

provider "helm" {
  alias = "helm-east"
  kubernetes = {
    # config_path = module.talos-proxmox-east.kubeconfig
    // config_path = "${path.module}/tmp/kubeconfig"
    // config_context = "admin@talos-east"
    host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"]
    client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"])
    client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["users"][0]["user"]["client-key-data"])
    cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])
  }
}

provider "helm" {
  alias = "helm-west"
  kubernetes = {
    // config_path = doppler_secrets.talos-proxmox-west.kubeconfig
    // config_path = "${path.module}/tmp/kubeconfig"
    // config_context = "admin@talos-west"
    host = yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["server"]
    client_certificate     = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-certificate-data"])
    client_key             = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["users"][0]["user"]["client-key-data"])
    cluster_ca_certificate = base64decode(yamldecode(data.doppler_secrets.this.map.KUBECONFIG_WEST)["clusters"][0]["cluster"]["certificate-authority-data"])
  }
}

# Configure the Doppler provider with the token
provider "doppler" {
  // Injected using `doppler run`
  doppler_token = var.doppler_token_dev
}