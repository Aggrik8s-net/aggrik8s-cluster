output "talosconfig-east" {
  depends_on  = [module.talos-proxmox-east]
  description = "Talos configuration file"
  value       = module.talos-proxmox-east.talosconfig
  sensitive   = true
}

output "talosconfig-west" {
  depends_on  = [module.talos-proxmox-west]
  description = "Talos configuration file"
  value       = module.talos-proxmox-west.talosconfig
  sensitive   = true
}

output "kubeconfig-east" {
  depends_on  = [module.talos-proxmox-east]
  description = "Kubeconfig file"
  value       = module.talos-proxmox-east.kubeconfig
  sensitive   = true
}

output "kubeconfig-west" {
  depends_on  = [module.talos-proxmox-west]
  description = "Kubeconfig file"
  value       = module.talos-proxmox-west.kubeconfig
  sensitive   = true
}


output "talos-proxmox-east_server" {
  depends_on  = [module.talos-proxmox-east.kubeconfig]
  description = "Our cluster's endpoint."
  value       = nonsensitive(doppler_secret.kubeconfig-server-east.computed)
  sensitive   = false
}


output "talos-proxmox-west_server" {
  depends_on  = [module.talos-proxmox-west.kubeconfig]
  description = "Our cluster's endpoint."
  value       = nonsensitive(doppler_secret.kubeconfig-server-west.computed)
  sensitive   = false
}

output "http_manifest_gateway-api_gatewayclasses" {
  value = data.http.manifest_gateway-api_gatewayclasses.id
}
output "http_manifest_gateway-api_gateways" {
  value = data.http.manifest_gateway-api_gateways.id
}
output "http_manifeset_gateway-api_httproutes" {
  value = data.http.manifest_gateway-api_httproutes.id
}
output "http_manifest_gateway-api_referencegrants" {
  value = data.http.manifest_gateway-api_referencegrants.id
}
output "http_manifest_gateway-api_grpcroutes" {
  value = data.http.manifest_gateway-api_grpcroutes.id
}
output "http_manifest_gateway-api_tlsroutes" {
  value = data.http.manifest_gateway-api_tlsroutes.id
}

output "east-gateway-api-gatewayclasses" {
  value = kubectl_manifest.gateway-api_gatewayclasses-east.id
}
output "east-gateway-api-gateways" {
  value = kubectl_manifest.gateway-api_gateways-east.id
}
output "east-gateway-api-httproutes" {
  value = kubectl_manifest.gateway-api_httproutes-east.id
}
output "east-gateway-api-referencegrants" {
  value = kubectl_manifest.gateway-api_referencegrants-east.id
}
output "east-gateway-api-grpcroutes" {
  value = kubectl_manifest.gateway-api_grpcroutes-east.id
}
output "east-gateway-api-tlsroutes" {
  value = kubectl_manifest.gateway-api_tlsroutes-east.id
}

output "west-gateway-api-gatewayclasses" {
  value = kubectl_manifest.gateway-api_gatewayclasses-west.id
}
output "west-gateway-api-gateways" {
  value = kubectl_manifest.gateway-api_gateways-west.id
}
output "west-gateway-api-httproutes" {

  value = kubectl_manifest.gateway-api_httproutes-west.id
}
output "west-gateway-api-referencegrants" {
  value = kubectl_manifest.gateway-api_referencegrants-west.id
}
output "west-gateway-api-grpcroutes" {
  value = kubectl_manifest.gateway-api_grpcroutes-east.id
}
output "west-gateway-api-tlsroutes" {
  value = kubectl_manifest.gateway-api_tlsroutes-west.id
}

