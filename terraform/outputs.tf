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
  value = kubectl_manifest.east-gateway-api_gatewayclasses.id
}
output "east-gateway-api-gateways" {
  value = kubectl_manifest.east-gateway-api_gateways.id
}
output "east-gateway-api-httproutes" {
  value = kubectl_manifest.east-gateway-api_httproutes.id
}
output "east-gateway-api-referencegrants" {
  value = kubectl_manifest.east-gateway-api_referencegrants.id
}
output "east-gateway-api-grpcroutes" {
  value = kubectl_manifest.east-gateway-api_grpcroutes.id
}
output "east-gateway-api-tlsroutes" {
  value = kubectl_manifest.east-gateway-api_tlsroutes.id
}

output "west-gateway-api-gatewayclasses" {
  value = kubectl_manifest.west-gateway-api_gatewayclasses.id
}
output "west-gateway-api-gateways" {
  value = kubectl_manifest.west-gateway-api_gateways.id
}
output "west-gateway-api-httproutes" {

  value = kubectl_manifest.west-gateway-api_httproutes.id
}
output "west-gateway-api-referencegrants" {
  value = kubectl_manifest.west-gateway-api_referencegrants.id
}
output "west-gateway-api-grpcroutes" {
  value = kubectl_manifest.east-gateway-api_grpcroutes.id
}
output "west-gateway-api-tlsroutes" {
  value = kubectl_manifest.west-gateway-api_tlsroutes.id
}

