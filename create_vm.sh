#!/usr/bin/env bash
set -euo pipefail

VM_NAME="minikube"
ZONE="ru-central1-a"
FOLDER_ID="$(yc config get folder-id)"
CORES=2
MEMORY="4GB"
CORE_FRACTION=100
DISK_SIZE=30
DISK_TYPE="network-ssd"
IMAGE_FAMILY="ubuntu-2204-lts"
SSH_KEY_PATH="${HOME}/.ssh/id_ed25519.pub" 
SUBNET_NAME="default-ru-central1-a"

echo "Актуальный образ Ubuntu 22.04:"
yc compute image get-latest-from-family "${IMAGE_FAMILY}" --folder-id standard-images

yc compute instance create \
  --name "${VM_NAME}" \
  --hostname "${VM_NAME}" \
  --zone "${ZONE}" \
  --folder-id "${FOLDER_ID}" \
  --cores "${CORES}" \
  --memory "${MEMORY}" \
  --core-fraction "${CORE_FRACTION}" \
  --create-boot-disk image-folder-id=standard-images,image-family="${IMAGE_FAMILY}",size="${DISK_SIZE}",type="${DISK_TYPE}",auto-delete=true \
  --network-interface subnet-name="${SUBNET_NAME}",nat-ip-version=ipv4 \
  --preemptible \
  --ssh-key "${SSH_KEY_PATH}" \

echo "VM создана. Получаем публичный IP:"
yc compute instance get "${VM_NAME}" --format json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'