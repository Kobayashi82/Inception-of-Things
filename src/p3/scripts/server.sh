#!/bin/bash

set -e

# Swapfile
if [ ! -f /swapfile ]; then
	fallocate -l 2G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# =============
# Installations
# =============

# Curl
apt-get update
apt-get install -y curl

# Docker
if ! command -v docker &> /dev/null; then
	apt-get install -y ca-certificates
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc

	tee /etc/apt/sources.list.d/docker.sources <<-EOF
	Types: deb
	URIs: https://download.docker.com/linux/debian
	Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
	Components: stable
	Signed-By: /etc/apt/keyrings/docker.asc
	EOF

	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io

	systemctl enable docker
	systemctl start docker
	usermod -aG docker vagrant
fi

# Kubectl
if ! command -v kubectl &> /dev/null; then
	curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl
fi

# K3d
if ! command -v k3d &> /dev/null; then
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# ArgoCD
if ! command -v argocd &> /dev/null; then
	curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
	install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
	rm argocd-linux-amd64
fi


# =============
# Configuration
# =============

# K3d
if ! k3d cluster list | grep -q "iot-cluster"; then
	k3d cluster create iot-cluster \
		--k3s-arg "--disable=traefik@server:0" \
		--k3s-arg "--disable=metrics-server@server:0"
fi
mkdir -p /home/vagrant/.kube
cp /root/.kube/config /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Namespaces
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# ArgoCD
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=argocd-server -n argocd
kubectl patch configmap argocd-cm -n argocd --patch '{"data": {"timeout.reconciliation": "60s"}}'
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl apply -f /tmp/k3s_config/application.yaml
if ! ss -tlnp | grep -q ':8080'; then
	kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 >/dev/null 2>&1 &
	sleep 5
fi
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
argocd account update-password --current-password $ARGOCD_PASSWORD --new-password "1234567890"

echo ""
echo "ArgoCD UI:  https://localhost:8888  (admin / 1234567890)"
echo "Web-App:    http://localhost:8080"
