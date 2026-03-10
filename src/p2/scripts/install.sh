#!/bin/bash

set -euo pipefail

# SWAPFILE
if [ ! -f /swapfile ]; then
	fallocate -l 1G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

apt-get update

# Install curl
if ! command -v curl &> /dev/null; then
	apt-get install -y curl
fi

# Install k3s
if ! command -v k3s &> /dev/null; then
	curl -sfL https://get.k3s.io | sh -s - \
        --node-ip ${K3S_IP} \
        --disable metrics-server \
        --disable local-storage \
        --write-kubeconfig-mode 644

	until kubectl get nodes --no-headers 2>/dev/null | grep -q .; do
		sleep 2
	done

	# Pre-pull the application
	k3s ctr images pull "docker.io/kobayashi82/iot-web-app:1.0.0" &> /dev/null

	# Apply manifest
	kubectl wait --for=condition=Ready node --all --timeout=120s
	kubectl apply -f /tmp/config/
fi
