variable "virtual_environment_endpoint" {
    description = "Proxmox Node URL"
    type        = string
    default     = "https://192.168.10.10:8006"
}

# Copyright (c) 2024 BB Tech Systems LLC

variable "proxmox_iso_datastore" {
    description = "Datastore to put the qcow2 image"
    type        = string
    default     = "local"
}

variable "proxmox_image_datastore" {
    description = "Datastore to put the VM hard drive images"
    type        = string
    default     = "cluster-lvm"
}

variable "proxmox_control_vm_cores" {
    description = "Number of CPU cores for the control VMs"
    type        = number
    default     = 8
}

variable "proxmox_worker_vm_cores" {
    description = "Number of CPU cores for the worker VMs"
    type        = number
    default     = 32
}

variable "proxmox_control_vm_memory" {
    description = "Memory in MB for the control VMs"
    type        = number
    default     = 32768
}

variable "proxmox_worker_vm_memory" {
    description = "Memory in MB for the worker VMs"
    type        = number
    default     = 65536
}

variable "proxmox_vm_type" {
    description = "Proxmox emulated CPU type, x86-64-v2-AES recommended"
    type        = string
    default     = "x86-64-v2-AES"
}

variable "proxmox_control_vm_disk_size" {
    description = "Proxmox control VM disk size in GB"
    type        = number
    default     = 32
}

variable "proxmox_worker_vm_disk_size" {
    description = "Proxmox worker VM disk size in GB"
    type        = number
    default     = 64
}

variable "proxmox_network_vlan_id" {
    description = "Proxmox network VLAN ID"
    type        = number
    default     = null
}
variable "proxmox_network_bridge" {
  description = "Proxmox network Bridge"
  type = string
  default = "vmbr0"
}

variable "talos_cluster_name" {
    description = "Name of the Talos cluster"
    type        = string
}

variable "talos_schematic_id" {
    # Generate your own at https://factory.talos.dev/
    # The this id has these extensions:
    # qemu-guest-agent (required)
    # If you make your own make sure you check this extension
    # The ID is independent of the version and architecture of the image
    description = "Schematic ID for the Talos cluster"
    type        = string
    # `default     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
    #
    # To find the schematic_id used to configure a running cluster:
    # talosctl --talosconfig ~/Talos/talosconfig get extensions -e 192.168.10.13
    #
    default     = "787b79bb847a07ebb9ae37396d015617266b1cef861107eaec85968ad7b40618"
}

variable "talos_version" {
    description = "Version of Talos to use"
    type        = string
}

variable "talos_arch" {
    description = "Architecture of Talos to use"
    type        = string
    default     = "amd64"
}

# Theses two variables are maps that control how many control and worker nodes are created
# and what their names are. The keys are the talos node names and the values are the proxmox node names
# to create the VMs on.
# Example:
# control_nodes = {
#   "talos-control-0" = "proxmox-node-0"
# }
# worker_nodes = {
#   "talos-worker-0" = "proxmox-node-0"
#   "talos-worker-1" = "proxmox-node-0"
# }
variable "control_nodes" {
    description = "Map of talos control node names to proxmox node names"
    type        = map(string)
}

variable "worker_nodes" {
    description = "Map of talos worker node names to proxmox node names"
    type        = map(string)
}

variable "control_machine_config_patches" {
    description = "List of YAML patches to apply to the control machine configuration"
    type        = list(string)
    default     = [
<<EOT
machine:
  install:
    disk: "/dev/vda"
  time:
    disabled: false # Indicates if the time service is disabled for the machine.
      # description: |
    servers:
      - time.cloudflare.com
    bootTimeout: 2m0s
  kubelet:
    extraArgs:
      rotate-server-certificates: true
cluster:
  network:
    cni:
      name: none
  proxy:    # to disable KUBE-PROXY
    disabled: true

  extraManifests:
    - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
    - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yamldshea@pi-manage-01:~/git/aggrik8s-cluster/terraform
EOT
    ]
}

variable "worker_machine_config_patches" {
    description = "List of YAML patches to apply to the worker machine configuration"
    type        = list(string)
    default     = [
<<EOT
machine:
  install:
    disk: "/dev/vda"
  time:
    disabled: false # Indicates if the time service is disabled for the machine.
      # description: |
    servers:
      - time.cloudflare.com
    bootTimeout: 2m0s
  kubelet:
    extraArgs:
      rotate-server-certificates: true
cluster:
  network:
    cni:
      name: none
  proxy:    # to disable KUBE-PROXY
    disabled: true

  extraManifests:
    - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
    - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
EOT
    ]
}

variable "worker_extra_disks" {
    # This allows for extra disks to be added to the worker VMs
    # TODO - Should we allow other things like host PCI devices as well E.g., GPUs?
    description = "Map of talos worker node name to a list of extra disk blocks for the VMs"
    type        = map(list(object({
        datastore_id = string
        size         = number
        file_format  = optional(string)
        file_id      = optional(string)
    })))
    default     = {}
}
