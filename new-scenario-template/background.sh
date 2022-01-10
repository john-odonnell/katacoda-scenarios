#!/bin/bash

# Update apt package index and install dependencies
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https

# Install kubectl and helm
snap install --classic kubectl
snap install --classic helm

# Install KinD
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind

# Creating a KinD Cluster with local image registry
docker network create kind
reg_port="5000"
docker run -d --restart=always -p "${reg_port}:${reg_port}" --name "kind-registry" --net=kind registry:2
reg_ip="$(docker inspect -f '{{.NetworkSettings.Networks.kind.IPAddress}}' kind-registry)"

cat <<EOF | ./kind create cluster --name "kind" --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_ip}:${reg_port}"]
EOF

# Pull and push Conjur CLI image
docker pull cyberark/conjur-cli:5-latest
docker image tag cyberark/conjur-cli:5-latest localhost:5000/conjur-cli:5-latest
docker image push localhost:5000/conjur-cli:5-latest

# Add and update CyberArk Helm repository
helm repo add cyberark https://cyberark.github.io/helm-charts
helm repo update

echo "DONE" > /opt/.setupcomplete
