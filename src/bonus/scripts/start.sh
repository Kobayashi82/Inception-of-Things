#!/bin/bash

set -e

# Start Docker if not running
systemctl start docker

# Start k3d cluster
k3d cluster start iot-cluster

# Wait for node to be ready
until kubectl wait node --all --for=condition=Ready --timeout=10s 2>/dev/null; do
	sleep 2
done

echo ""
echo "ArgoCD:   https://argocd.local:8443  (admin / aA1234567890*)"
echo "GitLab:   http://gitlab.local:8080   (root / aA1234567890*)"
echo "Web-App:  http://web-app.local:8080"
