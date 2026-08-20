#!/usr/bin/env bash
set -Eeuo pipefail

SSH_KEY="${HOME}/.ssh/id_ed25519"
SSH_USER="yc-user"
VM_IP="158.160.109.53"

read -r -d '' REMOTE_SCRIPT <<'EOF' || true
set -Eeuo pipefail

KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl kubectl.sha256

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64.sha256

echo "$(cat minikube-linux-amd64.sha256)  minikube-linux-amd64" | sha256sum --check

sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64 minikube-linux-amd64.sha256

echo "----- Версии установленных инструментов -----"
kubectl version --client
minikube version
EOF

echo "== Установка kubectl и Minikube на ${VM_IP} =="

ssh -i "${SSH_KEY}" \
    -o StrictHostKeyChecking=accept-new \
    "${SSH_USER}@${VM_IP}" \
    "bash -s" <<< "${REMOTE_SCRIPT}"

echo "== Установка завершена =="