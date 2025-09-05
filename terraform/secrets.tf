/*

Wwe use this pattern to pe-process our secrets and just save attributes

  host                   = yamldecode(doppler_secret.kubeconfig_east.computed)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(doppler_secret.kubeconfig_east.computed)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(doppler_secret.kubeconfig_east.computed)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(doppler_secret.kubeconfig_east.computed)["clusters"][0]["cluster"]["certificate-authority-data"])

*/

//i. resource "doppler_project.default" "aggrik8s-net" {
// }

data "doppler_secrets" "aggrik8s-cluster" {
  project = "aggrik8s-cluster"
  config  = "dev"
}

resource "doppler_secret" "kubeconfig_east" {
  depends_on = [module.talos-proxmox-east.kubeconfig]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_EAST"
  value = module.talos-proxmox-east.kubeconfig
}
resource "doppler_secret" "kubeconfig_west" {
  depends_on = [module.talos-proxmox-west.kubeconfig]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_WEST"
  value = module.talos-proxmox-west.kubeconfig
}
resource "doppler_secret" "kubeconfig-server-east" {
  depends_on = [module.talos-proxmox-east.kubeconfig,
                doppler_secret.kubeconfig_east]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_SERVER_EAST"
  value = yamldecode(module.talos-proxmox-east.kubeconfig)["clusters"][0]["cluster"]["server"]
}
resource "doppler_secret" "kubeconfig-server-west" {
  depends_on = [module.talos-proxmox-west.kubeconfig,
                doppler_secret.kubeconfig_west]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_SERVER_WEST"
  value = yamldecode(module.talos-proxmox-west.kubeconfig)["clusters"][0]["cluster"]["server"]
}

//
//   client_certificate     = base64decode(yamldecode(doppler_secret.kubeconfig_east.computed)["users"][0]["user"]["client-certificate-data"])
//
resource "doppler_secret" "client_certificate_east" {
  depends_on = [module.talos-proxmox-east.kubeconfig,
                doppler_secret.kubeconfig_east]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "CLIENT_CERTIFICATE_EAST"
  value = yamldecode(doppler_secret.kubeconfig_east.computed)["users"][0]["user"]["client-certificate-data"]
}
resource "doppler_secret" "client_certificate_west" {
  depends_on = [module.talos-proxmox-west.kubeconfig,
                doppler_secret.kubeconfig_west]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "CLIENT_CERTIFICATE_WEST"
  // value = yamldecode(module.talos-proxmox-west.kubeconfig)["clusters"][0]["cluster"]["server"]
  value = yamldecode(doppler_secret.kubeconfig_west.computed)["users"][0]["user"]["client-certificate-data"]
}

//
//    client_key             = base64decode(yamldecode(doppler_secret.kubeconfig_east.computed)["users"][0]["user"]["client-key-data"])
//
resource "doppler_secret" "client_key_east" {
  depends_on = [module.talos-proxmox-east.kubeconfig,
                doppler_secret.kubeconfig_east]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "CLIENT_KEY_EAST"
  value = yamldecode(doppler_secret.kubeconfig_east.computed)["users"][0]["user"]["client-key-data"]
}
resource "doppler_secret" "client_key_west" {
  depends_on = [module.talos-proxmox-west.kubeconfig,
                doppler_secret.kubeconfig_west]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "CLIENT_KEY_WEST"
  // value = yamldecode(module.talos-proxmox-west.kubeconfig)["clusters"][0]["cluster"]["server"]
  value = yamldecode(doppler_secret.kubeconfig_west.computed)["users"][0]["user"]["client-key-data"]
}

//
// cluster_ca_certificate = base64decode(yamldecode(doppler_secret.kubeconfig_east.computed)["clusters"][0]["cluster"]["certificate-authority-data"])
//
resource "doppler_secret" "cluster_ca_certificate_east" {
  depends_on = [module.talos-proxmox-east.kubeconfig,
                doppler_secret.kubeconfig_east]
  project    = "aggrik8s-cluster"
  config     = "dev"
  name       = "CLUSTER_CA_CERTIFICATE_EAST"
  value      = yamldecode(doppler_secret.kubeconfig_east.computed)["clusters"][0]["cluster"]["certificate-authority-data"]
}
resource "doppler_secret" "cluster_ca_certificate_west" {
  depends_on = [module.talos-proxmox-east.kubeconfig,
                doppler_secret.kubeconfig_west]
  project    = "aggrik8s-cluster"
  config     = "dev"
  name       = "CLUSTER_CA_CERTIFICATE_WEST"
  value      = yamldecode(doppler_secret.kubeconfig_west.computed)["clusters"][0]["cluster"]["certificate-authority-data"]
}

resource "doppler_secret" "talosconfig_east" {
  depends_on = [module.talos-proxmox-east.talosconfig,
                doppler_secret.kubeconfig_east]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "TALOSCONFIG_EAST"
  value = module.talos-proxmox-east.talosconfig
}
resource "doppler_secret" "talosconfig_west" {
  depends_on = [module.talos-proxmox-west.talosconfig,
                doppler_secret.kubeconfig_west]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "TALOSCONFIG_WEST"
  value = module.talos-proxmox-west.talosconfig
}

/*
resource "doppler_secret" "east-kubeconfig-server" {
  depends_on = [module.talos-proxmox-east.kubeconfig]
  project = "aggrik8s-cluster"
  config = "dev"
  name = "KUBECONFIG_EAST_SERVER"
  // value = module.talos-proxmox-east.kubeconfig
  value = yamldecode(module.talos-proxmox-east.kubeconfig)["clusters"][0]["cluster"]["server"]

}
*/

// output "resource_value" {
//   # Access the secret value
//   # nonsensitive used for demo purposes only
//   value = nonsensitive(doppler_secret.kubeconfig_east.value)
// }



// output "proxmox_user" {
//   sensitive = true
//   value = data.doppler_secrets.this.map.PROXMOX_USER
// }

// output "doppler_token" {
//   sensitive = true
//   value = data.doppler_secrets.this.map.DOPPLER_TOKEN
// }

// output "proxmox_api_token" {
//   sensitive = true
//   value = data.doppler_secrets.this.map.PROXMOX_API_TOKEN
// }

// output "proxmox_root_pwd" {
//   sensitive = true
//   value = data.doppler_secrets.this.map.PROXMOX_ROOT_PWD
// }
