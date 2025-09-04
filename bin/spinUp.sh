doppler run --name-transformer tf-var -- terraform apply  -auto-approve --target module.talos-proxmox-east --target module.talos-proxmox-west
# terraform
doppler run --name-transformer tf-var -- terraform apply  -auto-approve --target doppler_secret.kubeconfig_east --target doppler_secret.kubeconfig_west
doppler run --name-transformer tf-var -- terraform apply  -auto-approve --target doppler_secret.kubeconfig-server-east  --target doppler_secret.kubeconfig-server-west
doppler run --name-transformer tf-var -- terraform apply  -auto-approve --target doppler_secret.client_certificate_east --target secret.client_certificate_west
doppler run --name-transformer tf-var -- terraform apply  -auto-approve --target doppler_secret.client_key_east --target doppler_secret.client_key_west
doppler run --name-transformer tf-var -- terraform apply  -auto-approve --target doppler_secret.cluster_ca_certificate_east --target  doppler_secret.cluster_ca_certificate_west
