# aggrik8s-cluster
This project automates the provisioning of a monetizable mesh of Talos based Kubernetes clusters.

Talos is an immutable Linux distribution built specifally to run Kubernetes.  Talos nodes must be configured by using either `talosctl` or code such as Terraform, Ansible, Go, Python and such which use the `Talos API`. `talosctl` will be the primary adhoc administrative tool as there is no `ssh` and there are no `bash`, `systemctl`, `cat`, `find`, `sed` or any other familiar OSF tools.

## TLDR;
We use Terraform to provision Cilium Mesh of Talos based Kubernetes clusters.
- We spin up Kubernetees clusters using [bbtechsys/talos/proxmox"](https://registry.terraform.io/modules/bbtechsys/talos/proxmox/latest) which uses:
  - Proxmox VMs are provisioned using [bgp/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox),
  - Talos nodes and clusters managed using [siderolabs/talos Terraform provider](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0).
  - Talos `Image Factory` generation of `control-plane` and `worker-node` configurations are patched to handle our requirements.
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

