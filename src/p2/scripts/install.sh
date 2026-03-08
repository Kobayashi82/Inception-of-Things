#!/bin/bash

set -e

# Swapfile
if [ ! -f /swapfile ]; then
	fallocate -l 1G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

apt-get update

# Curl
if ! command -v curl &> /dev/null; then
	apt-get install -y curl
fi

if ! command -v k3s &> /dev/null; then
	curl -sfL https://get.k3s.io | sh -s - \
        --node-ip ${K3S_IP} \
        --disable metrics-server \
        --disable local-storage \
        --write-kubeconfig-mode 644
	echo 'alias k="kubectl"' >> /etc/profile.d/k3s.sh
	alias k="kubectl"
fi

until kubectl wait node --all --for=condition=Ready --timeout=10s 2>/dev/null; do
    sleep 2
done

kubectl apply -f /tmp/k3s_config/
