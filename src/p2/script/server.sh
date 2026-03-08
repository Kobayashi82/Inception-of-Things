#!/bin/sh

set -e

apt-get update
apt-get install -y curl

fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
echo 'alias k="kubectl"' >> /etc/profile.d/k3s.sh

curl -sfL https://get.k3s.io | sh -s - \
        --node-ip ${K3S_IP} \
        --disable metrics-server \
        --disable local-storage \
        --write-kubeconfig-mode 644

until kubectl get nodes 2>/dev/null | grep -q " Ready "; do
    sleep 1
done

kubectl apply -f /tmp/k3s_config/

echo "Waiting for ingress..."
until curl -s -o /dev/null -w "%{http_code}" http://${K3S_IP} | grep -q "200\|404"; do
    sleep 1
done
echo "Ingress ready!"
