#!/usr/bin/env bash
set -Eeuo pipefail

SSH_KEY="${HOME}/.ssh/id_ed25519"
SSH_USER="yc-user"
VM_IP="158.160.109.53"

read -r -d '' REMOTE_SCRIPT <<'EOF' || true
set -Eeuo pipefail

minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=3072 \
  --disk-size=20g

minikube status
kubectl get nodes -o wide
kubectl get pods --namespace=kube-system
EOF

echo "== Запуск Minikube на ${VM_IP} =="

ssh -i "${SSH_KEY}" \
    -o StrictHostKeyChecking=accept-new \
    "${SSH_USER}@${VM_IP}" \
    "bash -s" <<< "${REMOTE_SCRIPT}"

echo "== Кластер Minikube запущен =="