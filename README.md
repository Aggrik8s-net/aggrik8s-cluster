# TLDR;
## Purpose
This project spins up a mesh of [Talos Kubernetes clusters](https://www.talos.dev) running [Cilium](https://cilium.io/). 
## Overview
Talos is an immutable Linux distribution purpose built to run Kubernetes. Cilium is an [eBPF](https://ebpf.io/) based CNI which allows us to improve scalability and visibility by injecting eBPF code into Linux kernels. Terraform providers allow us to use the [Talos API](https://www.talos.dev/v1.10/reference/api/) to configure Talos nodes and wire them into Kubernetes clusters then use `kubectl` and `Helm` to configure the kubernetes bits required for platform components such as [Cilium on Talos](https://www.talos.dev/v1.10/kubernetes-guides/network/deploying-cilium/) and [rook-ceph](https://www.talos.dev/v1.10/kubernetes-guides/configuration/ceph-with-rook/).
## Goal
The `aggrik8s-net/aggrik8s-cluster` stack gives us a monetizable Service Mesh Platform ready to host revenue generating applications.  
## Status
The Cilium branch works but has a race condition involving Kubernetes credentials. This requires multiple `terraform apply` runs and bash helper scripts to automate things not yet terraformed. The stack does export the correct Talos and Kubernetes credentials for each cluster (after it is created) but, because the credentials were not known at plan time, the KUBECONFIG related bits will fail until we run `bin/getCreds.sh` to set up our cluster's KUBECONFIG and TALOSCONFIG files. At this point, we use `talosctl wipe disk vdb` to insure that the second disk on our worker nodes is wiped of partitions to prepare it for use by `rook-ceph`. Another `terraform apply` will successfully connect to our clusters and use `kubectl` & `Helm` to configure our K8s bits. We now have two working clusters, `talos-east` and `talos-west` with all nodes in `NotReady` status as required to install Cilium. Next, run `bin/cilium_config.sh` to install Cilium CNI and bring all nodes `Ready`. We use the Cilium CLI because `Cilium Helm charts` do not handle certain scenarios properly, the CLI always works. Hubble, Robusta, Rook-Ceph, Honeycomb OTEL, and several other Day-2 applications have been verified to work on the meshed clusters.
We are using [Doppler](https://www.doppler.com/platform/secrets-manager) to manage Proxmox, Terraform, and Kubernetes secrets. and have wired `aggrik8s-net/aggrik8s-cluster` into [aikido Security Scanner](https://www.aikido.dev/) and are using [Kubescape](https://kubescape.io/) with [Armo](https://hub.armosec.io/docs/armo-platform#how-armo-platform-works) for SecOps controls.
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

