// resource "doppler_project.default" "aggrik8s-net" {
// }

resource "doppler_secret" "kubeconfig_east" {
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_EAST"
  value = module.talos-proxmox-east.kubeconfig
}
resource "doppler_secret" "kubeconfig_west" {
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_WEST"
  value = module.talos-proxmox-west.kubeconfig
}
resource "doppler_secret" "talosconfig_east" {
  project = "aggrik8s-cluster"
  config = "dev"
  name = "TALOSCONFIG_EAST"
  value = module.talos-proxmox-east.talosconfig
}
resource "doppler_secret" "talosconfig_west" {
  project = "aggrik8s-cluster"
  config = "dev"
  name = "TALOSCONFIG_WEST"
  value = module.talos-proxmox-west.talosconfig
}

output "resource_value" {
  # Access the secret value
  # nonsensitive used for demo purposes only
  value = nonsensitive(doppler_secret.kubeconfig_east.value)
}

data "doppler_secrets" "this" {
  project = "aggrik8s-cluster"
  // config  = "your-config-name"
}

output "proxmox_user" {
  sensitive = true
  value = data.doppler_secrets.this.map.PROXMOX_USER
}

output "doppler_token" {
  sensitive = true
  value = data.doppler_secrets.this.map.DOPPLER_TOKEN
}

output "proxmox_api_token" {
  sensitive = true
  value = data.doppler_secrets.this.map.PROXMOX_API_TOKEN
}

output "proxmox_root_pwd" {
  sensitive = true
  value = data.doppler_secrets.this.map.PROXMOX_ROOT_PWD
}
