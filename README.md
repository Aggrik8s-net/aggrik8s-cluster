## TLDR;
m aggrik8s-net/aggrik8s-cluster
This project spins up a mesh of Kubernetes clusters running [Talos](https://www.talos.dev) and [Cilium](https://cilium.io/use-cases/cluster-mesh/).
The cluster mesh extends the Kubernetes control-plane to allow applications to use a Zero Trust model to run across multiple clusters. 
A depoyment can now be composed of pods hosted on multiple clusters.
<p align="center">
  <img src="https://cdn.sanity.io/images/xinsvxfu/production/52945d699a34350e33de7dc1d85182ae37b0715e-1600x938.png?auto=format&q=80&fit=clip&w=2560" width="675" title="Cilium Cluster Mesh">
</p>
This Terraform stack creates a mesh of two Talos Clusters ready for development of Edge based Kubernetes applications.



Talos and Cilium combined give us the ability to create a Kubernetes platforms ready to monetize!

[Talos](https://github.com/siderolabs/talos) is an immutable Linux distribution purpose built to run Kubernetes.

[Cilium](https://github.com/cilium/cilium) is an [eBPF](https://ebpf.io/) based CNI which dramatically improves scalability, cost efficiency, and observability of the cluster.

We use a Terraform module [bbtechsys/terraform-proxmox-talos](https://github.com/bbtechsys/terraform-proxmox-talos) to spin up Proxmox based Talos clusters with CNI disabled (required to install Cilium).
The module uses the [bpg/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox) provider to provision Talos VMs and the [siderolabs/terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos) provider to configure those VMs as our `control-plane` and `worker` nodes.
The stack uses [DopplerHQ/terraform-provider-doppler](https://github.com/DopplerHQ/terraform-provider-doppler) to create and inject secrets used by [hashicorp/terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes) to install k8s bits such as our Cilium CRD manifests and [hashicorp/terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm) for helm charts used to install resources such as `rook-ceph`.


## Goals for the next phase of the project
- Document ARMO before trial ends (3 days ?),
- Consider `talm` to manage `CozyStack` PaaS-Full clusters.
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
This recipe has been tested and verified to orchestrate the provisioning of our meshed Talos clusters.
1. [../bin/spinUp.sh](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/spinUp.sh) provisions the Talos Clusters and sets up our Doppler secrets.
2. [../bin/getCreds.sh](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/getCreds.sh) create local `talosconfig` and `kubeconfig` files and merge our `kubeconfig` files to support `kubectx -`.
3. [../bin/wipeVdb.sh](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/getCreds.sh)  -  prepare`vdb`to be adopted by Rook.
4. `export KUBECONFIG=./tmp/kubeconfig` point to our merged `kubeconfig` file.
5. `mv rook-ceph.tf rook-ceph.tf-` disable `rook-ceph` provisioning until after Cilium is installed.
5. `mv metrics-server.tf metrics-server.tf-` disable metrics-server provisioning until we patch config.
7. `doppler run --name-transformer tf-var -- terraform apply` installs our Kubernetes bits including CRD's we need to start Cilium.
8. [../bin/cilium-config.sh -i 1 -n talos-east -c admin@talos-east](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/cilium_config.sh) install Cilium on `talos-east`.
9. [../bin/cilium-config.sh -i 2 -n talos-west -c admin@talos-west](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/cilium/bin/cilium_config.sh) install Cilium on `talos-west`.
10. `mv rook-ceph.tf- rook-ceph.tf` enable `rook-ceph` provisioning now that Cilium CNI is installed.
11. `mv metrics-server.tf- metrics-server.tf` enable `rook-ceph` provisioning now that Cilium CNI is installed.
12. `doppler run --name-transformer tf-var -- terraform apply` installs our Kubernetes bits including CRD's we need to start Cilium.
13. `kubectl --context admin@talos-west delete secret cilium-ca -n kube-system` => secret "cilium-ca" deleted
14. `kubectl --context admin@talos-east get secret -n kube-system cilium-ca -o yaml |  kubectl --context admin@talos-west  create -f -`  => secret/cilium-ca created
15. ` cilium clustermesh enable --context admin@talos-east --service-type NodePort` enable 1/2 of our Cluster Mesh.
16. ` cilium clustermesh enable --context admin@talos-west --service-type NodePort` enable the other 1/2 of the Mesh.
17. `cilium clustermesh connect --context admin@talos-east --destination-context admin@talos-west` is how we make it so
18.  `cilium connectivity test --context admin@talos-east --multi-cluster admin@talos-west`  -  run cilium conn3ctivity test

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
