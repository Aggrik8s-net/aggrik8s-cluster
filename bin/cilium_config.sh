#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
      CLUSTER_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -c|--context)
      CLUSTER_CONTEXT="$2"
      shift # past argument
      shift # past value
      ;;
    -i|--cluster_id)
      CLUSTER_ID="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

echo "CLUSTER_NAME    = ${CLUSTER_NAME}"
echo "CLUSTER_CONTEXT = ${CLUSTER_CONTEXT}"
echo "CLUSTER_ID      = ${CLUSTER_ID}"
# echo "DEFAULT         = ${DEFAULT}"
# echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)

# if [[ -n $1 ]]; then
#     echo "Last line of file specified as non-opt/last argument:"
#     tail -1 "$1"
# fi
#
#     Utility script to allow repeatable installation of Cilium using the CLI.
#
#     We will (most likely) move to HELM at some point once we have the attributes nailed.
#
#     Procedure:
#                      1)  Start with zero state
#                      2)  terraform apply - creates east & west clusters then errors out
#                      3)  Run `../bin/getCreds.sh` to set up config files
#                      4)  terraform apply - creates all the Kubernetes bits using creds set up in #3
#                      5)  ../bin/cilium_config.sh  -  Installs cilium using CLI
#                      6)  cilium connectivity test
#
#

cilium install \
  --version v1.18.0-rc.0 \
  --set cluster.name=${CLUSTER_NAME} \
  --set cluster.id=${CLUSTER_ID}   \
  --context ${CLUSTER_CONTEXT}  \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  --set l2announcements.enabled=true \
  --set l2announcements.leaseDuration="3s" \
  --set l2announcements.leaseRenewDeadline="1s" \
  --set l2announcements.leaseRetryPeriod="500ms" \
  --set devices="{ens18}" \
  --set externalIPs.enabled=true \
  --set operator.replicas=2  \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set gatewayAPI.enabled=true \
    --set gatewayAPI.enableAlpn=true \
    --set gatewayAPI.enableAppProtocol=true


# cilium hubble enable

