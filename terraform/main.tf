
# main.tf
resource "local_file" "kubeconfig-east" {
  filename = "${path.module}/tmp/kubeconfig-east"
  content  = module.talos-proxmox-east.kubeconfig
}
resource "local_file" "talosconfig-east" {
  filename = "${path.module}/tmp/talosconfig-east"
  content  = module.talos-proxmox-east.talosconfig
}

resource "local_file" "kubeconfig-west" {
  filename = "${path.module}/tmp/kubeconfig-west"
  content  = module.talos-proxmox-west.kubeconfig
}
resource "local_file" "talosconfig-west" {
  filename = "${path.module}/tmp/talosconfig-west"
  content  = module.talos-proxmox-west.talosconfig
}

module "talos-proxmox-east" {
    # source  = "bbtechsys/talos/proxmox"
    source  = "./modules/talos_cilium"
    #version = "0.1.5"
    talos_cluster_name = "talos-east"
    talos_version = "1.10.4"
    control_nodes = {
        "cp-e-1" = "pve"
        "cp-e-2" = "pve"
        "cp-e-3" = "pve"
    }
    worker_nodes = {
        "wrk-e-1" = "pve"
        "wrk-e-2" = "pve"
        "wrk-e-3" = "pve"
    }

    worker_extra_disks = {
        "wrk-e-1" = [{
                            datastore_id = "cluster-lvm"
                            size         = 96
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-e-2" = [{
                            datastore_id = "cluster-lvm"
                            size         = 96
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-e-3" = [{
                            datastore_id = "cluster-lvm"
                            size         = 96
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
    }
}

module "talos-proxmox-west" {
    # depends_on = [module.talos-proxmox-east]
    # source  = "bbtechsys/talos/proxmox"
    source  = "./modules/talos_cilium"
    #version = "0.1.5"
    talos_cluster_name = "talos-west"
    talos_version = "1.10.4"
    control_nodes = {
        "cp-w-1" = "pve"
        "cp-w-2" = "pve"
        "cp-w-3" = "pve"
    }
    worker_nodes = {
        "wrk-w-1" = "pve"
        "wrk-w-2" = "pve"
        "wrk-w-3" = "pve"
    }
    worker_extra_disks = {
        "wrk-w-1" = [{
                            datastore_id = "cluster-lvm"
                            size         = 96
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-w-2" = [{
                            datastore_id = "cluster-lvm"
                            size         = 96
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
        "wrk-w-3" = [{
                            datastore_id = "cluster-lvm"
                            size         = 96
                            #file_format  = optional(string)
                            #file_id      = optional(string)
                      },]
    }
}

//
//  We have spun up a cluster, now get TALOSCONFIG and KUBECONFIG files.
//
resource "null_resource" "talos-proxmox-creds" {
   depends_on = [module.talos-proxmox-east, module.talos-proxmox-west]
   provisioner "local-exec" {
     // Run Terraform externally to copy output secrets to local files.
     command = "${path.module}/../bin/getCreds.sh"
   }
}

// resource "null_resource" "talos-proxmox-west" {
//   depends_on = [module.talos-proxmox-west]
//   provisioner "local_exec" {
//     // Run Terraform externally to copy output secrets to local files.
//     command = "${path.module}/../bin/getCreds.sh"
//   }
// }



//resource "get-creds" "talosconfig-east" {
//  depends_on = [module.talos-proxmox-east]
//}
//resource "get-creds" "talosconfig-west" {
//  depends_on = [module.talos-proxmox-west]
//}
