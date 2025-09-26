# Deploy Aggrik8s-net/aggrik8s-cluster
Describe the steps required to spin up multiple Talos Clusters meshed using Cilium CNI.
## Prerequisites
- Working [Aggrik8s-net/aggrik8s-fabric](https://github.com/Aggrik8s-net/aggrik8s-fabric/) or equivalent network infrastructure,
- Cluster details such as patch files are specified in [main.tf](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/main/terraform/main.tf) and [modules/talos_cilium/variables.tf](https://github.com/Aggrik8s-net/aggrik8s-cluster/blob/main/terraform/modules/talos_cilium/variables.tf),
- Secrets are injected using [Doppler](https://www.doppler.com) SaaS or Terraform TFVARS.
- Stale secrets in the SaaS or in the local environment need to be manually removed,
- -> Include Diagram of Cluster Mesh <-
## Notes
Cluster credentials for Talos and Kubernetes are exported both as [Doppler secrets](https://www.doppler.com/integrations/kubernetes) and as local `talosconfig` and `kubeconfig` files.
We need to enhance this procedure to remove stale secrets when we manually destroy the clusters.

We use the Cilium CLI to manage our environment as `Cilium Helm charts` do not always work correctly.

Our existing Ansible Playbooks have been verified to be reusable to configure `Day 2 Services` such as [Robusta](https://github.com/robusta-dev/robusta), [Honeycomb OTEL](https://docs.honeycomb.io/send-data/opentelemetry/).
SecOps is addressed using [Doppler](https://www.doppler.com/platform/secrets-manager) to manage our platform secrets and eBPF tools such as [Kubescape](https://kubescape.io/) with [Armo](https://hub.armosec.io/docs/armo-platform#how-armo-platform-works), [Inspektor-Gadget](https://github.com/inspektor-gadget/inspektor-gadget),  [Groundcover](https://www.groundcover.com/ebpf-sensor) and [Tetragon](https://github.com/cilium/tetragon/).

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

## Cluster Cleanup
Usually, we can do a `terraform destroy` and remove all provisioned resources, occasionally this will not work. 

When it is necessary we can zap all provisioned state  can `un-hork` whatever is wedged or sometimes its simpler to reset.
