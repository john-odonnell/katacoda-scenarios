#!/bin/bash
set +x

echo "Preparing environment..."
while [ ! -f /opt/.setupcomplete ]; do echo -n "."; sleep 5; done
echo
echo "Environment ready, including Kubernetes-in-Docker cluster and K8s tools."
