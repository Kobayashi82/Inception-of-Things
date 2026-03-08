#!/bin/bash

set -e

k3d cluster start iot-cluster

kubectl wait --for=condition=available --timeout=120s deployment -l app.kubernetes.io/name=argocd-server -n argocd

if ! ss -tlnp | grep -q ':8080'; then
	kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 &> /dev/null &
fi

echo ""
echo "ArgoCD UI:  https://localhost:8888  (admin / 1234567890)"
echo "Web-App:    http://localhost:8080"
