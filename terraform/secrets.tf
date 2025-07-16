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
