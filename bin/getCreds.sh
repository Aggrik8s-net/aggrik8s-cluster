#
#
#      Get our cluster's Talos and Kubernetes secrets.
#
#

# set -x

terraform output --raw talosconfig-east > tmp/talosconfig-east
chmod 600 tmp/talosconfig-east
terraform output --raw kubeconfig-east  > tmp/kubeconfig-east
chmod 600 tmp/kubeconfig-east

terraform output --raw talosconfig-west > tmp/talosconfig-west
chmod 600 tmp/talosconfig-west
terraform output --raw kubeconfig-west  > tmp/kubeconfig-west
chmod 600 tmp/kubeconfig-west

KUBECONFIG=tmp/kubeconfig-east:tmp/kubeconfig-west kubectl config view --flatten > tmp/kubeconfig
chmod 600 $KUBECONFIG
