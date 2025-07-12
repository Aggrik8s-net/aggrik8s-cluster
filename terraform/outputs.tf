output "talosconfig-east" {
    description = "Talos configuration file"
    value       = module.talos-proxmox-east.talosconfig
    sensitive   = true
}

output "talosconfig-west" {
    description = "Talos configuration file"
    value       = module.talos-proxmox-west.talosconfig
    sensitive   = true
}

output "kubeconfig-east" {
    description = "Kubeconfig file"
    value       = module.talos-proxmox-east.kubeconfig
    sensitive   = true
}

output "kubeconfig-west" {
    description = "Kubeconfig file"
    value       = module.talos-proxmox-west.kubeconfig
    sensitive   = true
}

output "talos-proxmox-east_server" {
    description = "Our cluster's endpoint."
    value       = var.east_host
    sensitive   = false
}

output "talos-proxmox-west_server" {
  description = "Our cluster's endpoint."
  value       = var.west_host
  sensitive   = false
}




