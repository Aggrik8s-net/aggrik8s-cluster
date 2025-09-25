# Define a variable so we can pass in our token
variable "doppler_token" {
  type        = string
  description = "A token to authenticate with Doppler for the dev config"
}
variable "doppler_token_dev" {
  type        = string
  description = "A token to authenticate with Doppler for the dev config"
}

variable "proxmox_api_token" {
  description = "Doppler managed secret injected as a TF_VAR."
  type        = string
  sensitive   = true
}

variable "proxmox_api_endpoint" {
  description = "Doppler managed secret injected as a TF_VAR."
  type        = string
  sensitive   = false
  default     = "https://192.168.88.10:8006"
}

variable "proxmox_root_pwd" {
  description = "Doppler managed secret injected as a TF_VAR."
  type        = string
  sensitive   = true
}

variable "proxmox_user" {
  description = "Doppler managed secret injected as a TF_VAR."
  type        = string
  sensitive   = false
}
