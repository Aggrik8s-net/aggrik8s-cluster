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

module "talos-proxmox-east" {
    # source  = "bbtechsys/talos/proxmox"
    source  = "./modules/talos_cilium"
    #version = "0.1.5"
    talos_cluster_name = "talos-east"
    talos_version = "1.10.4"
    control_nodes = {
        "cp-e-1" = "pve"
        "cp-e-2" = "pve"
        "cp-e-3" = "pve"
    }
    worker_nodes = {
        "wrk-e-1" = "pve"
        "wrk-e-2" = "pve"
        "wrk-e-3" = "pve"
    }

    worker_extra_disks = {
        "wrk-e-1" = [{
                            datastore_id = "pve-zfs-01"
                            size         = 128
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-e-2" = [{
                            datastore_id = "pve-zfs-01"
                            size         = 128
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-e-3" = [{
                            datastore_id = "pve-zfs-01"
                            size         = 128
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
    }
}

module "talos-proxmox-west" {
    # depends_on = [module.talos-proxmox-east]
    # source  = "bbtechsys/talos/proxmox"
    source  = "./modules/talos_cilium"
    #version = "0.1.5"
    talos_cluster_name = "talos-west"
    talos_version = "1.10.4"
    control_nodes = {
        "cp-w-1" = "pve"
        "cp-w-2" = "pve"
        "cp-w-3" = "pve"
    }
    worker_nodes = {
        "wrk-w-1" = "pve"
        "wrk-w-2" = "pve"
        "wrk-w-3" = "pve"
    }
    worker_extra_disks = {
        "wrk-w-1" = [{
                            datastore_id = "pve-zfs-01"
                            size         = 128
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-w-2" = [{
                            datastore_id = "pve-zfs-01"
                            size         = 128
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-w-3" = [{
                            datastore_id = "pve-zfs-01"
                            size         = 128
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
    }
}

