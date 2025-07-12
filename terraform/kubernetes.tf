/*

       Install Cilium CRDs prior to spinning up Cilium.

       We need to do this so ApiGateway comes up properly..

 */

// Set TF_VAR_host using:
//  KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-east | yq '.clusters[0].cluster["server"]'
variable "east_host" {
  type = string
  default = ""
}
//  KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.clusters[0].cluster["server"]'
variable "west_host" {
  type = string
  default = ""
}

// Set TF_VAR_client_certificate using:
// KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-east | yq '.users[0]["user"]["client-certificate-data"]'
variable "east_client_certificate" {
  type = string
  default = ""
}
// KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.users[0]["user"]["client-certificate-data"]'
variable "west_client_certificate" {
  type = string
  default = ""
}

//  Set TF_VAR_client_key using:
//  KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-east | yq '.users[0]["user"]["client-key-data"]'
variable "east_client_key" {
  type = string
  default = ""
}
//  KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.users[0]["user"]["client-key-data"]'
variable "west_client_key" {
  type = string
  default = ""
}

//  Set TF_VAR_cluster_ca_certificate using:
//  KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-east | yq '.clusters[0].cluster["certificate-authority-data"]'
variable "east_cluster_ca_certificate" {
  type = string
  default = ""
}
//  KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.clusters[0].cluster["certificate-authority-data"]'
variable "west_cluster_ca_certificate" {
  type = string
  default = ""
}

provider "kubernetes" {
  alias = "talos-proxmox-east"
  host = var.east_host

  client_certificate     = base64decode(var.east_client_certificate)
  client_key             = base64decode(var.east_client_key)
  cluster_ca_certificate = base64decode(var.east_cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "talos-proxmox-west"
  host = var.west_host

  client_certificate     = base64decode(var.west_client_certificate)
  client_key             = base64decode(var.west_client_key)
  cluster_ca_certificate = base64decode(var.west_cluster_ca_certificate)
}
