# aggrik8s-cluster
## TLDR;
This project provisions a monetizable platform composed of a mesh of Talos Kubernetes clusters running Cilium. Talos is an immutable Linux distribution built specifically to run Kubernetes.  This project uses Terraform providers to access the `Talos API`, `kubectl`, and `Helm` to allow provisioning and configuration of a turnkey Cilium Cluster Mesh.  All adhoc cluster administration uses `talosctl` as there is no `ssh` and there are no beloved OSF tools such as `bash`, `systemctl`, `cat`, `find`, `sed`.
## Status
The Cilium branch works but currently has a race condition involving Kubernetes credentials. The stack does export the correct Talos and Kubernetes credentials for each cluster, but, as they were not available at plan time, the stack fails the first time it is run. A simple helper script uses Terraform to retreive the newly generated credentials and sets up the required KUBECONFIG files. A second run of `terraform apply` now finds Kubernetes credentials and our Terraform stack uses `kubectl` and `Helm` to configure the Kubernetes bits. After second `terraform apply`, we have spun up two clusters, `talos-easty` and `talos-west` with all nodes haaving `NotReady` status as our code disables `CNI`. Cilium can always be installed using the `cilium CLI` and sometimes it can be installed using `Helm` but the  as well as installing Cilium. 
The stack will be fully automated once the best integration strategy is determined. For instance, Helm can be usind to install Cilium or we can use the Cilium CLI which properly handles complicated scenarios not properly handled using Helm.
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

