# aggrik8s-cluster
## TLDR;
This project spins up a mesh of Talos based Kubernetes clusters running Cilium. Talos is an immutable Linux distribution purpose built to run Kubernetes. Cilium is an eBPF based Kubernetes CNI which allows us to improve Kubernetes scalability and visibility by running eBPF code in the kernel. Terraform providers allow us to use the `Talos API` to configure Talos nodes and wire them into Kubernetes clusters then use `kubectl` and `Helm` to configure all the bits required for Cilium's Service Mesh and other platform components such as `rook-ceph` storage and OTEL telemetry.
The `aggrik8s-net/aggrik8s-cluster` stack gives us a monetizable Service Mesh Platform ready to host revenue generating applications.  
## Status
The Cilium branch works but has a race condition involving Kubernetes credentials. This requires multiple `terraform apply` runs with bash scripts to automate the bits not yet terraformed. The stack does export the correct Talos and Kubernetes credentials for each cluster (after they are created) but, as the credentials were not known at plan time, the KUBECONFIG related bits will fail until we run `bin/getCreds.sh` to export our cluster's KUBECONFIG files.  After setting up KUBECONFIG, a second `terraform apply` connects to our clusters and uses `kubectl` and `Helm` to configure the required K8s bits. At this point, we have two working clusters, `talos-east` and `talos-west` with all nodes in `NotReady` status because we disabled CNI which is required to install Cilium. We now run `bin/cilium_config.sh` to install Cilium CNI and bring all nodes `Ready`. We are using the Cilium CLI because the `Cilium Helm` charts do not handle certain scenarios properly, the CLI always works. Hubble, Robusta, Rook-Ceph, Honeycomb OTEL, and several other applications have been verified to work on the cluster.
We are using Doppler to manage Proxmox, Terraform, and Kubernetes secrets. We have wired `aggrik8s-net/aggrik8s-cluster` into `aikaid Security` for configuration and image scanning. We have also tested Kubescape and are working on integration with Armo.
## Design
We use Terraform to provision Cilium Mesh of Talos based Kubernetes clusters.
- We spin up Kubernetees clusters using [bbtechsys/talos/proxmox"](https://registry.terraform.io/modules/bbtechsys/talos/proxmox/latest) which uses:
  - Proxmox VMs are provisioned using [bgp/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox),
  - Talos nodes and clusters managed using [siderolabs/talos Terraform provider](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0).
  - Talos `Image Factory` generation of `control-plane` and `worker-node` configurations are patched to handle our requirements.
- [DopplerHQ/doppler](https://registry.terraform.io/providers/DopplerHQ/doppler/latest/docs) manages Secrets for Terraform and Kubernetes,
- CSI ObjectSore, BlockStore, and FileSystem services using [rook-ceph on Talos](https://www.talos.dev/v1.10/kubernetes-guides/configuration/ceph-with-rook/) and [digitalocean/csi-digitalocean](https://github.com/digitalocean/csi-digitalocean),
- CNI wired up following [Cilium on Talos](https://www.talos.dev/v1.10/kubernetes-guides/network/deploying-cilium/) provides Cilium features, 
- Ansible Playbooks for Day-2 services such as `Honeycomb OTEL`, `Robusta`, `OLMv1` will be merged into the stack over time.
## Telemetry
- Hubble for network traffic analysis (see IP .
- Tetragon for SecOps (see system calls)
- Robusta for Cloud based Cluster DevOps workflows.
- `Groundcover` for Inversion of Cost for OTEL Cloud storage. They only ingest metadaata, all actual OTEL data remains in cluster.
## Status
The Cilium branch works but requires at least two `terraform apply` and several bash helper scripts for setting up Talos & Kubernetes credentials as well as installing Cilium. 
The stack will be fully automated once the best integration strategy is determined. For instance, Helm can be usind to install Cilium or we can use the Cilium CLI which properly handles complicated scenarios not properly handled using Helm.

