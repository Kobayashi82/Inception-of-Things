#!/bin/sh

set -e

echo "Installing curl..."

apt-get update
apt-get install -y curl

echo "Installing Kubernete..."

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC=server sh - 

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 1
done
cp /var/lib/rancher/k3s/server/node-token /vagrant/token
