# aggrik8s-cluster
## TLDR;
This project spins up a mesh of Talos based Kubernetes clusters running Cilium. Talos is an immutable Linux distribution purpose built to run Kubernetes. Cilium is an eBPF based Kubernetes CNI which allows us to remove Kube-Proxy and improves scalability while providing visibility directly into the Linux Kernel. We use Terraform providers to access the `Talos API` as well as `kubectl` and `Helm` allowing us to wire the nodes into clusters and provision Kubernetes resources for turnkey Cilium Clusters ready to mesh.  
## Status
The Cilium branch works but has a race condition involving Kubernetes credentials. This requires multiple `terraform apply` runs with several bash scripts automating the bits not yet terraformed. The stack does export the correct Talos and Kubernetes credentials for each cluster, but, as they were not available at plan time, the stack fails until the external KUBECONFIG files are configured. A second run of `terraform apply` after seetting up KUBECONFIG credentials allows our Terraform stack to use `kubectl` and `Helm` to configure the K8s bits. After the second `terraform apply`, we have spun up two clusters, `talos-east` and `talos-west` with all nodes in `NotReady` status ready to run a script containing `cilium install <options>` to setup Cilium CNI whicch brings all nodes to `Ready` status. Cilium can always be installed using the `cilium` CLI but `Helm` does not handle certain scenarios properly. Isovalent provides sevral options for settup Cilium but for now, we are using the CLI as it always works. Cilium configuration will be fully automated once the best option is determined.
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
