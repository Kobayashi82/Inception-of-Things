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
		local traefik_ip=$(kubectl get svc -n kube-system traefik -o jsonpath='{.spec.clusterIP}')
		local bcrypt_pass=$(argocd account bcrypt --password "$PASSWORD")
		local mtime=$(date -u +%Y-%m-%dT%H:%M:%SZ)

		# Install ArgoCD
		helm upgrade --install argocd argo/argo-cd \
			--namespace argocd \
			--values /tmp/config/argocd.yaml \
			--set "repoServer.hostAliases[0].ip=$traefik_ip" \
			--set "configs.secret.argocdServerAdminPassword=$bcrypt_pass" \
			--set "configs.secret.argocdServerAdminPasswordMtime=$mtime" \
			--wait \
			--timeout 300s

		# Apply manifest
		kubectl apply -f /tmp/config/application.yaml
	fi
}

# GITLAB
install_gitlab() {
	# Run curl commands inside the toolbox pod
	gitlab_curl() {
		local pod=$(kubectl get pod -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')
		kubectl exec -n gitlab "$pod" -- curl -sS "$@" 2>/dev/null
	}

	if ! helm status gitlab -n gitlab &>/dev/null; then
		# Create GitLab secret
		kubectl create secret generic gitlab-root-password \
			--namespace gitlab \
			--from-literal=initial_root_password="$PASSWORD" \
			--dry-run=client -o yaml | kubectl apply -f -

		# Install GitLab
		helm upgrade --install gitlab gitlab/gitlab \
			--version "9.9.2" \
			--namespace gitlab \
			--values /tmp/config/gitlab.yaml \
			--timeout 600s \
			--wait

		# Wait for GitLab to be ready
		kubectl wait --for=condition=ready --timeout=900s pod -l app=toolbox -n gitlab
		until gitlab_curl "http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/-/readiness" | grep -q '"status":"ok"'; do
			sleep 5
		done

		# Create root token via gitlab-rails
		local toolbox_pod=$(kubectl get pod -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')
		local root_token=$(kubectl exec -n gitlab "$toolbox_pod" -- gitlab-rails runner "require 'securerandom'; user = User.find_by_username('root') or abort('root user not found'); token_value = SecureRandom.hex(32); token = user.personal_access_tokens.create!(name: \"bootstrap-token-#{Time.now.to_i}\", scopes: [:api], expires_at: 365.days.from_now.to_date); token.set_token(token_value); token.save!; puts token_value")

		# Create user vzurera
		local user_id=$(gitlab_curl --fail-with-body \
			--header "PRIVATE-TOKEN: $root_token" \
			-X POST "http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/users" \
			--data "email=vzurera@gitlab.local" \
			--data "username=vzurera" \
			--data "password=$PASSWORD" \
			--data "name=vzurera" \
			--data "skip_confirmation=true" | jq -r '.id')

		# Create user token
		local user_token=$(gitlab_curl --fail-with-body \
			--header "PRIVATE-TOKEN: $root_token" \
			-X POST "http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/users/$user_id/personal_access_tokens" \
			--data "name=vzurera-token-$(date +%s)" \
			--data "scopes[]=api" \
			--data "scopes[]=read_repository" \
			--data "scopes[]=write_repository" | jq -r '.token')

		# Create repo inception-of-things
		local project_id=$(gitlab_curl --fail-with-body \
			--header "PRIVATE-TOKEN: $user_token" \
			-X POST "http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/projects" \
			--data "name=inception-of-things" \
			--data "initialize_with_readme=true" \
			--data "visibility=public" | jq -r '.id')

		# Build the commit payload
		local payload=$(jq -n \
			--arg d "$(base64 -w 0 /tmp/config/repo/deployments.yaml)" \
			--arg i "$(base64 -w 0 /tmp/config/repo/ingress.yaml)" \
			--arg s "$(base64 -w 0 /tmp/config/repo/services.yaml)" \
			'{
				branch: "main",
				commit_message: "Upload manifests",
				actions: [
					{ action: "create", file_path: "deployments.yaml", content: $d, encoding: "base64" },
					{ action: "create", file_path: "ingress.yaml",     content: $i, encoding: "base64" },
					{ action: "create", file_path: "services.yaml",    content: $s, encoding: "base64" }
				]
			}')

		# Push the commit
		gitlab_curl --fail-with-body \
			--header "PRIVATE-TOKEN: $user_token" \
			--header "Content-Type: application/json" \
			-X POST "http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/projects/$project_id/repository/commits" \
			--data "$payload" > /dev/null
	fi
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
	kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace dev    --dry-run=client -o yaml | kubectl apply -f -
}

# UTILS
install_utils() {
	apt-get update

	# Install curl
	if ! command -v curl &> /dev/null; then
		apt-get install -y curl
	fi

	# Install jq
	if ! command -v jq &> /dev/null; then
		apt-get install -y jq
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
		helm repo add gitlab https://charts.gitlab.io/ >/dev/null 2>&1 || true
		helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
		helm repo update
	fi
}

# SWAPFILE
create_swapfile() {
	if [ ! -f /swapfile ]; then
		fallocate -l 2G /swapfile
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
install_gitlab
install_argocd
