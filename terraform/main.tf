terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.75.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "~> 0.7.1"
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

module "talos" {
    # source  = "bbtechsys/talos/proxmox"
    source  = "./modules/talos_cilium"
    #version = "0.1.5"
    talos_cluster_name = "prox-talos"
    talos_version = "1.9.5"
    control_nodes = {
        "cp-1" = "pve"
        "cp-2" = "pve"
        "cp-3" = "pve"
    }
    worker_nodes = {
        "worker-0" = "pve"
        "worker-1" = "pve"
        "worker-2" = "pve"
    }
}


output "talos_config" {
    description = "Talos configuration file"
    value       = module.talos.talos_config
    sensitive   = true
}

output "kubeconfig" {
    description = "Kubeconfig file"
    value       = module.talos.kubeconfig
    sensitive   = true
}