#/bin/bash

# Update apt package index and install dependencies
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https

# Install Docker
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io
docker --version

# Install kubectl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get install -y kubectl
kubectl version --client

# Install KinD
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
kind --version

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get install helm

# Creating a KinD Cluster with local image registry
docker network create kind
reg_port="5000"
docker run -d --restart=always -p "${reg_port}:${reg_port}" --name "kind-registry" --net=kind registry:2
reg_ip="$(docker inspect -f '{{.NetworkSettings.Networks.kind.IPAddress}}' kind-registry)"

cat <<EOF | kind create cluster --name "kind" --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
containerdConfigPatches: 
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_ip}:${reg_port}"]
EOF

docker pull cyberark/conjur-cli:5-latest
docker image tag cyberark/conjur-cli:5-latest localhost:5000/conjur-cli:5-latest
docker image push localhost:5000/conjur-cli:5-latest
