#!/bin/sh

set -e

echo "Installing curl..."

apt-get update
apt-get install -y curl

echo "Waiting for server token..."

while [ ! -f /vagrant/token ]; do
    sleep 1
done

echo "Installing Kubernete..."

curl -sfL https://get.k3s.io | K3S_TOKEN=`cat /vagrant/token` INSTALL_K3S_EXEC=agent sh -
