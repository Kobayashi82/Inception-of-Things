#!/bin/bash

set -euo pipefail

GITLAB_USER=${GITLAB_USER:-"vzurera"}
GITLAB_PASS=${GITLAB_PASS:-"aA123456789*"}
GITLAB_USERPASS=${GITLAB_USERPASS:-$GITLAB_PASS}
GITLAB_REPO=${GITLAB_REPO:-"inception-of-things"}
ARGOCD_PASS=${ARGOCD_PASS:-"aA123456789*"}

# Start Docker
systemctl start docker

# Start k3d cluster
k3d cluster start iot-cluster

# Wait for node to be ready
until kubectl wait node --all --for=condition=Ready --timeout=10s 2>/dev/null; do
	sleep 2
done

echo ""
echo "ArgoCD:   http://argocd.local:8080   (admin => $ARGOCD_PASS)"
echo "GitLab:   http://gitlab.local:8080   ($GITLAB_USER => $GITLAB_USERPASS)"
echo "Web-App:  http://web-app.local:8080"
