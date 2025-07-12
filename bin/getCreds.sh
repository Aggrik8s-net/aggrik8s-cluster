#
#
#      Get our cluster's Talos and Kubernetes secrets.
#
#

# set -x

terraform output --raw talosconfig-east > tmp/talosconfig-east
terraform output --raw kubeconfig-east  > tmp/kubeconfig-east

terraform output --raw talosconfig-west > tmp/talosconfig-west
terraform output --raw kubeconfig-west  > tmp/kubeconfig-west

