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

# Creating a KinD cluster
./kind create cluster --name "kind"

echo "DONE" > /opt/.setupcomplete
