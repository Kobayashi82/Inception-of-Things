#!/bin/bash

set -euo pipefail

PASSWORD="aA123456789*"

# --------------
#      MAIN     
# --------------

k3d cluster start iot-cluster

echo ""
echo "ArgoCD:   http://argocd.local:8080   (admin        => $PASSWORD)"
echo "GitLab:   http://gitlab.local:8080   (root/vzurera => $PASSWORD)"
echo "Web-App:  http://web-app.local:8080"
