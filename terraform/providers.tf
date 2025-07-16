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
  alias          = "kubectl-west"
  // host                   = var.west_host
  config_path    = "${path.module}/tmp/kubeconfig-west"
  // config_path    = yamldecode(module.talos-proxmox-west.kubeconfig)
  // config_context = "admin@talos-west"
  // client_certificate     = base64decode(var.west_client_certificate)
  // client_key             = base64decode(var.west_client_key)
  // cluster_ca_certificate = base64decode(var.west_cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "talos-proxmox-east"
  // host = var.east_host
  config_path    = "${path.module}/tmp/kubeconfig"
  config_context = "admin@talos-east"
  // config_path = module.talos-proxmox-east.kubeconfig
  //
  // These need to be set up externally using ../bin/setTF_VARS.sh
  //
  // client_certificate     = base64decode(var.east_client_certificate)
  // client_key             = base64decode(var.east_client_key)
  // cluster_ca_certificate = base64decode(var.east_cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "talos-proxmox-west"
  // host = var.west_host
  // config_path = module.talos-proxmox-west.kubeconfig
  config_path = "${path.module}/tmp/kubeconfig-west"
  config_context = "admin@talos-west"
  //
  //  These need to be set up externally using ../bin/setTF_VARS.sh
  //
  // client_certificate     = base64decode(var.west_client_certificate)
  // client_key             = base64decode(var.west_client_key)
  // cluster_ca_certificate = base64decode(var.west_cluster_ca_certificate)
}

provider "helm" {
  alias = "helm-east"
  kubernetes = {
    # config_path = module.talos-proxmox-east.kubeconfig
    config_path = "${path.module}/tmp/kubeconfig"
    config_context = "admin@talos-east"
  }
}

provider "helm" {
  alias = "helm-west"
  kubernetes = {
    # config_path = module.talos-proxmox-west.kubeconfig
    config_path = "${path.module}/tmp/kubeconfig"
    config_context = "admin@talos-west"
  }
}

# Configure the Doppler provider with the token
provider "doppler" {
  // Injected using `doppler run`
  doppler_token = var.doppler_token
}

//output "test-module-output" {
//  value = module.talos-proxmox-west.kubeconfig
//  sensitive = false
//}
