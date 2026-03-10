#!/bin/bash

set -euo pipefail

# SWAPFILE
if [ ! -f /swapfile ]; then
	fallocate -l 2G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# VARIABLES
GITLAB_USER=${GITLAB_USER:-"user"}
GITLAB_PASS=${GITLAB_PASS:-"aA123456789*"}
GITLAB_USERPASS=${GITLAB_USERPASS:-$GITLAB_PASS}
GITLAB_REPO=${GITLAB_REPO:-"inception-of-things"}
ARGOCD_PASS=${ARGOCD_PASS:-"aA123456789*"}
GITLAB_CHART_VERSION="9.9.2"
GITLAB_INTERNAL_URL="http://gitlab-webservice-default.gitlab.svc.cluster.local:8181"

# GITLAB
toolbox_pod() {
	kubectl get pod -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}'
}

gitlab_curl() {
	kubectl exec -n gitlab "$(toolbox_pod)" -- curl -sS "$@" 2>/dev/null
}

gitlab_rails() {
	kubectl exec -n gitlab "$(toolbox_pod)" -- gitlab-rails runner "$1"
}

gitlab_install() {
	apt-get install -y jq

	if ! command -v helm &> /dev/null; then
		curl -sSf https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
	fi

	kubectl create secret generic gitlab-root-password \
		--namespace gitlab \
		--from-literal=initial_root_password=$GITLAB_PASS \
		--dry-run=client -o yaml | kubectl apply -f -

	helm repo add gitlab https://charts.gitlab.io/ >/dev/null 2>&1 || true
	helm repo update
	helm upgrade --install gitlab gitlab/gitlab \
		--version "$GITLAB_CHART_VERSION" \
		--namespace gitlab \
		--values /tmp/config/gitlab.yaml \
		--timeout 600s \
		--wait

	kubectl wait --for=condition=ready --timeout=900s pod -l app=webservice -n gitlab
	kubectl wait --for=condition=ready --timeout=900s pod -l app=toolbox -n gitlab

	until gitlab_curl "$GITLAB_INTERNAL_URL/-/readiness" | grep -q '"status":"ok"'; do
		sleep 5
	done

	local file
	local files_json="[]"
	for file in /tmp/config/repo/*; do
		local filename=$(basename "$file")
		local content=$(base64 -w 0 "$file")
		files_json=$(printf '%s' "$files_json" | jq -c --arg name "$filename" --arg body "$content" '. + [{file_path: $name, content: $body}]')
	done

	local root_token=$(gitlab_rails "require 'securerandom'; user = User.find_by_username('root') or abort('root user not found'); token_value = SecureRandom.hex(32); token = user.personal_access_tokens.create!(name: \"bootstrap-token-#{Time.now.to_i}\", scopes: [:api], expires_at: 365.days.from_now.to_date); token.set_token(token_value); token.save!; puts token_value")

	local user_id=$(gitlab_curl --fail-with-body --header "PRIVATE-TOKEN: $root_token" "$GITLAB_INTERNAL_URL/api/v4/users?username=$GITLAB_USER" | jq -r 'if type == "array" and length > 0 then .[0].id else empty end')
	if [ -z "$user_id" ]; then
		user_id=$(gitlab_curl --fail-with-body --header "PRIVATE-TOKEN: $root_token" -X POST "$GITLAB_INTERNAL_URL/api/v4/users" \
			--data "email=$GITLAB_USER@gitlab.local" \
			--data "username=$GITLAB_USER" \
			--data "password=$GITLAB_USERPASS" \
			--data "name=$GITLAB_USER" \
			--data "skip_confirmation=true" | jq -r '.id')
	fi

	local user_token=$(gitlab_curl --fail-with-body --header "PRIVATE-TOKEN: $root_token" -X POST "$GITLAB_INTERNAL_URL/api/v4/users/$user_id/personal_access_tokens" \
		--data "name=$GITLAB_USER-token-$(date +%s)" \
		--data "scopes[]=api" \
		--data "scopes[]=read_repository" \
		--data "scopes[]=write_repository" | jq -r '.token')

	local project_id=$(gitlab_curl --fail-with-body --header "PRIVATE-TOKEN: $user_token" "$GITLAB_INTERNAL_URL/api/v4/projects?simple=true&owned=true&search=$GITLAB_REPO" | jq -r --arg path "$GITLAB_USER/$GITLAB_REPO" '.[] | select(.path_with_namespace == $path) | .id' | head -n 1)
	if [ -z "$project_id" ]; then
		project_id=$(gitlab_curl --fail-with-body --header "PRIVATE-TOKEN: $user_token" -X POST "$GITLAB_INTERNAL_URL/api/v4/projects" \
			--data "name=$GITLAB_REPO" \
			--data "initialize_with_readme=true" \
			--data "visibility=private" | jq -r '.id')
	fi

	gitlab_rails "require 'json'; require 'base64'; project = Project.find($project_id); user = User.find_by_username('$GITLAB_USER') or abort('project owner not found'); branch = project.default_branch.presence || 'main'; files = JSON.parse(%q{$files_json}); actions = files.map do |entry|; file_path = entry.fetch('file_path'); action = project.repository.blob_at_branch(branch, file_path) ? :update : :create; { action: action, file_path: file_path, content: Base64.decode64(entry.fetch('content')) }; end; project.repository.commit_files(user, branch_name: branch, message: 'Seed repository manifests', actions: actions) unless actions.empty?"

	USER_TOKEN=$(printf '%s\n' "$user_token")
}

# ARGOCD
argocd_install() {
	if ! command -v argocd &> /dev/null; then
		curl -sSfL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
		install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
		rm argocd-linux-amd64
	fi

	kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

	kubectl patch deployment argocd-server -n argocd --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"}]' || true
	kubectl patch deployment argocd-repo-server -n argocd --type merge -p "{
		\"spec\": {
			\"template\": {
				\"spec\": {
					\"hostAliases\": [
						{
							\"ip\": \"$(kubectl get svc -n kube-system traefik -o jsonpath='{.spec.clusterIP}')\",
							\"hostnames\": [\"gitlab.local\"]
						}
					]
				}
			}
		}
	}"

	kubectl rollout status deployment/argocd-server -n argocd --timeout=120s
	kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=120s

	kubectl patch configmap argocd-cm -n argocd --type merge -p '{
		"data": {
			"timeout.reconciliation": "60s"
		}
	}' >/dev/null

	kubectl patch secret argocd-secret -n argocd --type merge -p "{
		\"stringData\": {
			\"admin.password\": \"$(argocd account bcrypt --password "$ARGOCD_PASS")\",
			\"admin.passwordMtime\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
		}
	}"

	kubectl rollout restart deployment/argocd-server -n argocd
	kubectl rollout status deployment/argocd-server -n argocd --timeout=120s

	attempt=0
	until gitlab_curl --fail-with-body --user "oauth2:$USER_TOKEN" \
		"$GITLAB_INTERNAL_URL/$GITLAB_USER/$GITLAB_REPO.git/info/refs?service=git-upload-pack" | grep -q "git-upload-pack"; do
		attempt=$((attempt + 1))
		if [ "$attempt" -ge 24 ]; then
			echo "GitLab repository is not ready" >&2
			exit 1
		fi
		sleep 5
	done

	kubectl create secret generic gitlab-repo \
		--namespace argocd \
		--from-literal=type=git \
		--from-literal=url="$GITLAB_INTERNAL_URL/$GITLAB_USER/$GITLAB_REPO.git" \
		--from-literal=username="oauth2" \
		--from-literal=password="$USER_TOKEN" \
		--dry-run=client -o yaml | kubectl apply -f -

	kubectl label secret gitlab-repo -n argocd argocd.argoproj.io/secret-type=repository --overwrite

	sed -e "s|__GITLAB_USER__|$GITLAB_USER|g" -e "s|__GITLAB_REPO__|$GITLAB_REPO|g" /tmp/config/application.yaml > /tmp/config/application.final.yaml
	kubectl apply -f /tmp/config/argocd.yaml
	kubectl apply -f /tmp/config/application.final.yaml
}

# K3D
k3d_install() {
	apt-get update
	apt-get install -y curl

	if ! command -v docker &> /dev/null; then
		apt-get install -y docker.io
		usermod -aG docker vagrant
		systemctl enable docker
		systemctl start docker
	fi

	if ! command -v kubectl &> /dev/null; then
		curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
		rm kubectl
	fi

	if ! command -v k3d &> /dev/null; then
		curl -sSf https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	fi

	if ! k3d cluster list | grep -q "iot-cluster"; then
		k3d cluster create iot-cluster \
			--k3s-arg "--disable=metrics-server@server:0" \
			--port "80:80@loadbalancer"
		mkdir -p /home/vagrant/.kube
		cp /root/.kube/config /home/vagrant/.kube/config
		chown vagrant:vagrant /home/vagrant/.kube/config
	fi

	kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace dev    --dry-run=client -o yaml | kubectl apply -f -
}

k3d_install
gitlab_install
argocd_install
