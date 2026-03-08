#!/bin/bash

set -e

until kubectl wait node --all --for=condition=Ready --timeout=10s 2>/dev/null; do
	sleep 2
done

# Wait for ingress
echo "Waiting for ingress..."
until curl -s -o /dev/null -w "%{http_code}" http://${K3S_IP} | grep -q "200\|404"; do
	sleep 1
done
echo "Ingress ready!"
