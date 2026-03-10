#!/bin/bash

set -euo pipefail

PASSWORD="aA123456789*"

# --------------
#   FUNCTIONS
# --------------

# ARGOCD
install_argocd() {
	# Install ArgoCD CLI
	if ! command -v argocd &> /dev/null; then
		curl -sSfL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
		install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
		rm argocd-linux-amd64
	fi

	if ! helm status argocd -n argocd &>/dev/null; then
		# Dynamic values
		local bcrypt_pass=$(argocd account bcrypt --password "$PASSWORD")
		local mtime=$(date -u +%Y-%m-%dT%H:%M:%SZ)

		# Install ArgoCD
		helm upgrade --install argocd argo/argo-cd \
			--namespace argocd \
			--values /tmp/config/argocd.yaml \
			--set "configs.secret.argocdServerAdminPassword=$bcrypt_pass" \
			--set "configs.secret.argocdServerAdminPasswordMtime=$mtime" \
			--wait \
			--timeout 300s
	fi

	# Apply manifest
	kubectl apply -f /tmp/config/application.yaml
}

# K3D
install_k3d() {
	# Install kubectl
	if ! command -v kubectl &> /dev/null; then
		curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		rm kubectl
	fi

	# Install k3d
	if ! command -v k3d &> /dev/null; then
		curl -sSf https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	fi

	# Create cluster
	if ! k3d cluster list | grep -q "iot-cluster"; then
		k3d cluster create iot-cluster \
			--k3s-arg "--disable=metrics-server@server:0" \
			--port "80:80@loadbalancer"
		mkdir -p /home/vagrant/.kube
		cp /root/.kube/config /home/vagrant/.kube/config
		chown vagrant:vagrant /home/vagrant/.kube/config
	fi

	# Create namespaces
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
}

# UTILS
install_utils() {
	apt-get update

	# Install curl
	if ! command -v curl &> /dev/null; then
		apt-get install -y curl
	fi

	# Install docker
	if ! command -v docker &> /dev/null; then
		apt-get install -y docker.io
		usermod -aG docker vagrant
		systemctl enable docker
		systemctl start docker
	fi

	# Install helm
	if ! command -v helm &> /dev/null; then
		curl -sSf https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
	fi

	helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
	helm repo update
}

# SWAPFILE
create_swapfile() {
	if [ ! -f /swapfile ]; then
		fallocate -l 1G /swapfile
		chmod 600 /swapfile
		mkswap /swapfile
		swapon /swapfile
		echo '/swapfile none swap sw 0 0' >> /etc/fstab
	fi
}

# --------------
#      MAIN
# --------------

create_swapfile
install_utils
install_k3d
install_argocd
