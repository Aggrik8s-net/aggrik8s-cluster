# aggrik8s-cluster
This project automates spinning up a mesh of Talos based Kubernetes clusters using Cilium Mesh. Talos is an immutable Linux distribution built specifally to run Kubernetes.  
Talos nodes must be configured by using either `talosctl` or code such as Terraform, Ansible, Go, Python which use the `Talos API`. `talosctl` is the primary administrative tool for adhoc interactions as there is no `ssh` and there are no `bash`, `systemctl`, `cat`, `find`, `sed` or any of their family of OSF tools.

## TLDR;
We use Terraform to spin up multiple Talos Kubernetes clusters which are meshed using Cilium Mesh. 
This gives the full set of Cilium features including L2 IPAM, L2 Load Balanmcing, L3 BGP support, Hubble Observability, Cilium Policy management and more. 
- Use [bbtechsys/talos/proxmox](https://registry.terraform.io/modules/bbtechsys/talos/proxmox/latest) to spin up multiple Proxmox based Talos clusters.
  - [bgp/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox) talks to our Proxmox server(s),
  - [siderolabs/talos Terraform provider](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0) manages clusters of Talos nodes,
  - Talos `Image Factory` operationalizes generation of `control-plane` and `worker-node` configuration which we patch to customize the nodesto meet our requirements.
- [DopplerHQ/doppler](https://registry.terraform.io/providers/DopplerHQ/doppler/latest/docs) manages Secrets for Terraform and Kubernetes,
- CSI ObjectSore, BlockStore, and FileSystem services using both [rook-ceph on Talos](https://www.talos.dev/v1.10/kubernetes-guides/configuration/ceph-with-rook/) and [digitalocean/csi-digitalocean](https://github.com/digitalocean/csi-digitalocean),
- CNI wired up following [Cilium on Talos](https://www.talos.dev/v1.10/kubernetes-guides/network/deploying-cilium/) iliumprovides Cloud based management of all secrets 
- Ansible Playbooks for Day-2 services such as `Honeycomb OTEL`, `Robusta`, `OLMv1` have been tested and will be added to the stack over time.
## Telemetry
- Hubble for network traffic analysis (see IP .
- Tetragon for SecOps (see system calls)
- Robusta for Cloud based Cluster DevOps workflows.
- `Groundcover` for Inversion of Cost for OTEL Cloud storage. They only ingest metadaata, all actual OTEL data remains in cluster.
## Status
The Cilium branch works but requires at least two `terraform apply` and several bash helper scripts for setting up Talos & Kubernetes credentials as well as installing Cilium. 
The stack will be fully automated once the best integration strategy is determined. For instance, Helm can be usind to install Cilium or we can use the Cilium CLI which properly handles complicated scenarios not properly handled using Helm.

