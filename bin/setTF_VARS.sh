#
#     Inject ENV into Terraform using terraform generated KUUBECONFIG
#
#     This is working but might be able to read the kubeconfig directly from filesystem.
#
#     The  hashicorp/kubernetes  provider uses theese for both east and west clusters.
#

#set -x

export TF_VAR_east_host=`KUBECONFIG=tmp/kubeconfig-east kubectl config view --minify --flatten --context=admin@talos-east | yq '.clusters[0].cluster["server"]'| awk '{print substr($1,2,length($1)-2)}'`
export TF_VAR_west_host=`KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.clusters[0].cluster["server"]'| awk '{print substr($0,2,length($0)-2)}'`

# Set TF_VAR_client_certificate using:
export TF_VAR_east_client_certificate=`KUBECONFIG=tmp/kubeconfig-east kubectl config view --minify --flatten --context=admin@talos-east | yq '.users[0]["user"]["client-certificate-data"]'| awk '{print substr($0,2,length($0)-2)}'`
export TF_VAR_west_client_certificate=`KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.users[0]["user"]["client-certificate-data"]'| awk '{print substr($0,2,length($0)-2)}'`

#  Set TF_VAR_client_key using:
export TF_VAR_east_client_key=`KUBECONFIG=tmp/kubeconfig-east kubectl config view --minify --flatten --context=admin@talos-east | yq '.users[0]["user"]["client-key-data"]' | awk '{print substr($0,2,length($0)-2)}'`
export TF_VAR_west_client_key=`KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.users[0]["user"]["client-key-data"]' | awk '{print substr($0,2,length($0)-2)}'`

#  Set TF_VAR_cluster_ca_certificate using:
export TF_VAR_east_cluster_ca_certificate=`KUBECONFIG=tmp/kubeconfig-east kubectl config view --minify --flatten --context=admin@talos-east | yq '.clusters[0].cluster["certificate-authority-data"]'| awk '{print substr($0,2,length($0)-2)}'`
export TF_VAR_west_cluster_ca_certificate=`KUBECONFIG=tmp/kubeconfig-west kubectl config view --minify --flatten --context=admin@talos-west | yq '.clusters[0].cluster["certificate-authority-data"]'| awk '{print substr($0,2,length($0)-2)}'`

