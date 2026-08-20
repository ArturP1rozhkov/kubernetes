#!/usr/bin/env bash
set -Eeuo pipefail

SSH_KEY="${HOME}/.ssh/id_ed25519"
SSH_USER="yc-user"
VM_IP="158.160.109.53"

read -r -d '' REMOTE_SCRIPT <<'EOF' || true
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
CODENAME="${VERSION_CODENAME:-${UBUNTU_CODENAME:-jammy}}"

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<REPO
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
REPO

sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

docker --version
docker compose version
EOF

echo "== Установка Docker на ${VM_IP} =="

ssh -i "${SSH_KEY}" \
    -o StrictHostKeyChecking=accept-new \
    "${SSH_USER}@${VM_IP}" \
    "bash -s" <<< "${REMOTE_SCRIPT}"

echo "== Docker успешно установлен на ${VM_IP} =="
echo "Открой новую SSH-сессию и выполни: docker ps"