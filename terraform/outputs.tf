output "talos-config-east" {
    description = "Talos configuration file"
    value       = module.talos-proxmox-east.talosconfig
    sensitive   = true
}

output "talos-config-west" {
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




