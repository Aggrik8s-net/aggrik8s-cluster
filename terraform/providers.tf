locals {
  do_s3_endpoint_url = ""
  state_bucket       = ""
  state_file_name    = ""
}
// aggrik8s-cluster needs to be templated using Jinja
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }
    # endpoint = "https://nyc3.digitaloceanspaces.com"

    bucket       = "aggrik8s-cluster"
    key          = "terraform.tfstate"
    use_lockfile = true
    # Deactivate a few AWS-specific checks
    skip_credentials_validation = true
    # skip_requesting_account_id  = true
    skip_requesting_account_id = true
    skip_metadata_api_check    = true
    skip_region_validation     = true
    # skip_s3_checksum            = true
    skip_s3_checksum = true
    region           = "nyc3"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    cilium = {
      source  = "littlejo/cilium"
      version = "~> 0.3.1"
      configuration_aliases = [cilium.cilium-east,
      cilium.cilium-west]
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      configuration_aliases = [ # kubernetes.kubeconfig-east,
        # kubernetes.kubeconfig-west,
        kubernetes.talos-proxmox-east,
      kubernetes.talos-proxmox-west]
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
      configuration_aliases = [helm.helm-east,
      helm.helm-west]
    }
    // kubectl = {
    //   source = "gavinbunney/kubectl"
    //   version = "1.19.0"
    //   configuration_aliases = [kubectl.kubectl-east, kubectl.kubectl-west]
    // }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
    doppler = {
      source = "DopplerHQ/doppler"
      version = "1.20.0"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = ">= 1.28.0" # Use the latest stable version
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.67.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_endpoint
  // api_token  =  var.proxmox_api_token
  api_token = data.doppler_secrets.aggrik8s-cluster.map.PROXMOX_API_TOKEN
  insecure  = true
  ssh {
    agent = true
    // username = var.proxmox_user
    // password = var.proxmox_root_pwd
    username = data.doppler_secrets.aggrik8s-cluster.map.PROXMOX_USER
    password = data.doppler_secrets.aggrik8s-cluster.map.PROXMOX_ROOT_PWD
  }
}

provider "cilium" {
  # Configuration options
  // config_path = "${path.module}/kubeconfig-east"
  // config_path = "${path.module}/kubeconfig"
  // config_context = "admin@talos-east"
  alias                  = "cilium-east"
  host                   = doppler_secret.kubeconfig-server-east.computed
  client_certificate     = base64decode(doppler_secret.client_certificate_east.computed)
  client_key             = base64decode(doppler_secret.client_key_east.computed)
  cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_east.computed)
}

/*
output "kube_secret_KUBECONFIG_EAST" {
    value = nonsensitive(yamldecode(doppler_secret.kubeconfig_east.computed))
    //    yamldecode(data.doppler_secrets.aggrik8s-cluster.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"]
output "kube_secret_cluster_ca_data" {
    value = nonsensitive(yamldecode(data.doppler_secrets.aggrik8s-cluster.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])
}
output "kube_secret_cluster_server" {
    value = nonsensitive(yamldecode(data.doppler_secrets.aggrik8s-cluster.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"])
}
*/

provider "cilium" {
  # Configuration options
  // config_path = "${path.module}/kubeconfig"
  // config_context = "admin@talos-west"
  alias                  = "cilium-west"
  host                   = doppler_secret.kubeconfig-server-west.computed
  client_certificate     = base64decode(doppler_secret.client_certificate_west.computed)
  client_key             = base64decode(doppler_secret.client_key_west.computed)
  cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_west.computed)
}

provider "kubectl" {
  alias = "kubectl-east"
  // config_path    = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-east"

  host                   = doppler_secret.kubeconfig-server-east.computed
  client_certificate     = base64decode(doppler_secret.client_certificate_east.computed)
  client_key             = base64decode(doppler_secret.client_key_east.computed)
  cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_east.computed)
}

provider "kubectl" {
  #depends_on = [ doppler_secret.kubeconfig_west ]
  alias = "kubectl-west"
  // config_path    = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-west"

  host                   = doppler_secret.kubeconfig-server-west.computed
  client_certificate     = base64decode(doppler_secret.client_certificate_west.computed)
  client_key             = base64decode(doppler_secret.client_key_west.computed)
  cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_west.computed)
}

provider "kubernetes" {
  alias = "talos-proxmox-east"

  // config_path    = "${path.module}/tmp/kubeconfig"
  // config_context = "admin@talos-east"
  // config_path = module.talos-proxmox-east.kubeconfig
  host                   = doppler_secret.kubeconfig-server-east.computed
  client_certificate     = base64decode(doppler_secret.client_certificate_east.computed)
  client_key             = base64decode(doppler_secret.client_key_east.computed)
  cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_east.computed)
}

/*
output "kube_secret_host" {
    value = nonsensitive(yamldecode(doppler_secret.kubeconfig_east.computed)["clusters"][0]["cluster"]["server"])
}

output "kube_secret_client-certificate-data" {
    value = nonsensitive(yamldecode(data.doppler_secrets.aggrik8s-cluster.map.KUBECONFIG_EAST)["users"][0]["user"]["client-certificate-data"])
}
output "kube_secret_cluster_ca_data" {
    value = nonsensitive(yamldecode(data.doppler_secrets.aggrik8s-cluster.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["certificate-authority-data"])
}
output "kube_secret_cluster_server" {
    value = nonsensitive(yamldecode(data.doppler_secrets.aggrik8s-cluster.map.KUBECONFIG_EAST)["clusters"][0]["cluster"]["server"])
}
*/


provider "kubernetes" {
  alias = "talos-proxmox-west"

  host                   = doppler_secret.kubeconfig-server-west.computed
  client_certificate     = base64decode(doppler_secret.client_certificate_west.computed)
  client_key             = base64decode(doppler_secret.client_key_west.computed)
  cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_west.computed)
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
    host                   = doppler_secret.kubeconfig-server-east.computed
    client_certificate     = base64decode(doppler_secret.client_certificate_east.computed)
    client_key             = base64decode(doppler_secret.client_key_east.computed)
    cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_east.computed)
  }
}

provider "helm" {
  alias = "helm-west"
  kubernetes = {
    // config_path = doppler_secrets.talos-proxmox-west.kubeconfig
    // config_path = "${path.module}/tmp/kubeconfig"
    // config_context = "admin@talos-west"
    host                   = doppler_secret.kubeconfig-server-west.computed
    client_certificate     = base64decode(doppler_secret.client_certificate_west.computed)
    client_key             = base64decode(doppler_secret.client_key_west.computed)
    cluster_ca_certificate = base64decode(doppler_secret.cluster_ca_certificate_west.computed)
  }
}

# Configure the Doppler provider with the token
provider "doppler" {
  // Injected using `doppler run`
  doppler_token = var.doppler_token_dev
}

provider "auth0" {
  domain        = data.doppler_secrets.aggrik8s-cluster.map.AUTH0_DOMAIN
  client_id     = data.doppler_secrets.aggrik8s-cluster.map.AUTH0_CLIENT_ID
  client_secret = data.doppler_secrets.aggrik8s-cluster.map.AUTH0_CLIENT_SECRET
  // debug         = "<debug>"
}

provider "digitalocean" {
  token             = data.doppler_secrets.aggrik8s-cluster.map.DO_TOKEN
  spaces_access_id  = data.doppler_secrets.aggrik8s-cluster.map.DO_SPACES_ACCESS_ID
  spaces_secret_key = data.doppler_secrets.aggrik8s-cluster.map.DO_SPACES_SECRET_KEY
}

