# aggrik8s-cluster
## TLDR;
This project spins up a mesh of Talos based Kubernetes clusters running Cilium. Talos is an immutable Linux distribution purpose built to run Kubernetes. Cilium is an eBPF based Kubernetes CNI which allows us to improve Kubernetes scalability and visibility by running eBPF code directly in the Linux Kernel. We use Terraform providers to access the `Talos API` as well as `kubectl` and `Helm` allowing us to wire the Talos nodes into Kubernetes clusters and configure the Kubernetes resources needed to establish a Service Mesh. The `aggrik8s-cluster` stack gives us a Service Mesh Platform ready to monetize.  
## Status
The Cilium branch works but has a race condition involving Kubernetes credentials. This requires multiple `terraform apply` runs with several bash scripts automating the bits not yet terraformed. The stack does try to export the correct Talos and Kubernetes credentials for each cluster, but, as the credentials are not available at plan time, the stack will not progress until we run the `bin/getCreds.sh` script to install required KUBECONFIG files.  After setting up KUBECONFIG, a second `terraform apply` connects to our clusters and uses `kubectl` and `Helm` to configure the K8s bits. At this point, we have two clusters, `talos-east` and `talos-west` with all nodes in `NotReady` status which is required to install Cilium. We now run `bin/cilium_config.sh` to setup Cilium CNI and bring all nodes to `Ready` status. We are currently using the CLI because `Helm` does not handle certain scenarios properly. We have moved to Doppler to manage Proxmox, Terraform, and Kubernetes secrets. 
## Design
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
All adhoc cluster administration uses `talosctl` as there is no `ssh` and there are no beloved OSF tools such as `bash`, `systemctl`, `cat`, `find`, `sed`.
