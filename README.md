## TLDR;
This project provisions a mesh of [Talos](https://www.talos.dev) Kubernetes clusters using [Cilium cluster Mesh](https://cilium.io/use-cases/cluster-mesh/). 
A cluster mesh extends the Kubernetes' control-plane allowing applications to be composed of resources hosted on multiple clusters. 
Use cases such as `Follow-the-Sun NOC` or `Disaster Recovery` are simplified dramatically using applications hosted on meshed clusters.
<p align="center">
  <img src="https://cdn.sanity.io/images/xinsvxfu/production/52945d699a34350e33de7dc1d85182ae37b0715e-1600x938.png?auto=format&q=80&fit=clip&w=2560" width="675" title="Cilium Cluster Mesh">
</p>

## Description
[Talos](https://github.com/siderolabs/talos) is an immutable Linux distribution purpose built to run Kubernetes - it is configured using a single `YAML` and there no `ssh` . 

[Cilium](https://github.com/cilium/cilium) is an [eBPF](https://ebpf.io/) based Kubernetes CNI which improves scalability, cost efficiency, and observability of the cluster.

We use a combination of Terraform and Ansible to provision and administer our platform. 
The [bbtechsys/terraform-proxmox-talos](https://github.com/bbtechsys/terraform-proxmox-talos) Terraform module spins up Talos clusters using [bpg/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox) to provision Talos VMs and [siderolabs/terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos) to configure those VMs as our Kubernetes cluster's `control-plane` and `worker` nodes.
The stack uses [DopplerHQ/terraform-provider-doppler](https://github.com/DopplerHQ/terraform-provider-doppler) to create and inject secrets used by [hashicorp/terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes) to install k8s bits (such as Cilium CRD manifests) and [hashicorp/terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm) for helm charts support. We use both Terraform and Ansible to provision resources such as `rook-ceph` and [robusta](https://home.robusta.dev/).


## Goals for the next phase of the project
~~- Document ARMO before trial ends (3 days ?),~~
- Terraform Mikrotik Fabrik to support multiple AZ model, this is required for Ciliumm Cluster Mesh develoopment, 
- add `piCluster`, our RaspberryPi 5 based [rancherfederal/rk2-ansible](https://github.com/rancherfederal/rke2-ansible) cluster to the Cilium Cluster Mesh.
- Consider `talm` to manage `CozyStack` PaaS-Full clusters to leversge Day-2 support.
- Document Cilium Debug Tooling:
  - Deploy the Starwars applicatiopn using CI/CD,
  - Use Hubble UI to explore Starwars app,
  - Use Tetragon to explore Starwars app,
- Refactor the network layer:
    - Use VLAN to provision multiple NICs on our Talos nodes,
    - Provide VXLAN overlay using Mikrotik,
    - Providie BGP using Mikrotik and Cilium.

## Status
The Terraform stack works but requires bash helper scripts to orchestrate multiple `terraform apply --target <foo>` commands required to handle dependency tracking gaps in the Terraform plan phase.  helper scripts for setting up Talos & Kubernetes credentials as well as installing Cilium.
The stack will be fully automated once the best integration strategy is determined. For instance, Helm can be usind to install Cilium or we can use the Cilium CLI which properly handles complicated scenarios not properly handled using Helm.
We have verified the reusability of existing `Ansible Playbooks` to install `Day 2 Services` such as [Robusta](https://docs.robusta.dev/master/#), [Ollama](https://ollama.com) and [Honeycomb OTEL](https://docs.honeycomb.io/send-data/opentelemetry/collector/).



## Cluster Mesh Deployment
This recipe has been tested and verified to orchestrate the provisioning of our meshed Talos clusters; the procedure does depend on `podCIDR` to be unique for each cluster.
1. [../bin/spinUp.sh](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/spinUp.sh) provisions the Talos Clusters and sets up our Doppler secrets.
2. [../bin/getCreds.sh](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/getCreds.sh) create local `talosconfig` and `kubeconfig` files and merge our `kubeconfig` files to support `kubectx -`.
3. [../bin/wipeVdb.sh](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/getCreds.sh)  -  prepare`vdb`to be adopted by Rook.
4. `export KUBECONFIG=./tmp/kubeconfig` point to our merged `kubeconfig` file.
5. `mv rook-ceph.tf rook-ceph.tf-` disable `rook-ceph` provisioning until after Cilium is installed.
5. `mv metrics-server.tf metrics-server.tf-` disable metrics-server provisioning until we patch config.
7. `terraform taint doppler_secret.kubeconfig_west` => fix this suspected race condition issue
8. `doppler run --name-transformer tf-var -- terraform apply` installs our Kubernetes bits including CRD's we need to start Cilium.
9. [../bin/cilium_config.sh -i 1 -n talos-east -c admin@talos-east --pod_cidr "10.244.0.0/16"](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/cilium_config.sh) install Cilium on `talos-east`.
10. [../bin/cilium_config.sh -i 2 -n talos-west -c admin@talos-west --pod_cidr "10.245.0.0/16"](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/cilium_config.sh) install Cilium on `talos-west`.
11. `mv rook-ceph.tf- rook-ceph.tf` enable `rook-ceph` provisioning now that Cilium CNI is installed.
12. `mv metrics-server.tf- metrics-server.tf` enable `rook-ceph` provisioning now that Cilium CNI is installed.
13. `doppler run --name-transformer tf-var -- terraform apply` installs or Kubernetes bits including CRD's we need to start Cilium.
14. `kubectl --context admin@talos-west delete secret cilium-ca -n kube-system` => secret "cilium-ca" deleted
15. `kubectl --context admin@talos-east get secret -n kube-system cilium-ca -o yaml |  kubectl --context admin@talos-west  create -f -`  => secret/cilium-ca created
16. ` cilium clustermesh enable --context admin@talos-east --service-type NodePort` enable 1/2 of our Cluster Mesh.
17. ` cilium clustermesh enable --context admin@talos-west --service-type NodePort` enable the other 1/2 of the Mesh.
18. `cilium clustermesh connect --context admin@talos-east --destination-context admin@talos-west` is how we make it so
19. `cilium connectivity test --context admin@talos-east --multi-cluster admin@talos-west`  -  run cilium conn3ctivity test

Both clusters are good to go.

Our Cluster credentials for Talos and Kubernetes have been exported both as [Doppler secrets](https://www.doppler.com/integrations/kubernetes) and as local `talosconfig` and `kubeconfig` files. 
We are using the Cilium CLI to manage our environment because `Cilium Helm charts` do not always work correctly.
Our existing Ansible Playbooks have been verified to be reusable to configure `Day 2 Services` such as [Robusta](https://github.com/robusta-dev/robusta), [Honeycomb OTEL](https://docs.honeycomb.io/send-data/opentelemetry/).
SecOps is addressed using [Doppler](https://www.doppler.com/platform/secrets-manager) to manage our platform secrets and eBPF tools such as [Kubescape](https://kubescape.io/) with [Armo](https://hub.armosec.io/docs/armo-platform#how-armo-platform-works), [Inspektor-Gadget](https://github.com/inspektor-gadget/inspektor-gadget),  [Groundcover](https://www.groundcover.com/ebpf-sensor) and [Tetragon](https://github.com/cilium/tetragon/).

<p align="center">
  <img src="https://tetragon.io/images/smart_observability.png" width="500" title="Tetragon eBPF Sensor">
</p>


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
## Applications
- Ollama
- 
