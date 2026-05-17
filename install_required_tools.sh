#!/bin/bash

# =========================================================
# SkillPulse Advanced DevOps Environment Setup Script
# Installs everything needed for skillpulse:
# - Docker
# - Docker Compose
# - Kubernetes CLI
# - Kind Cluster
# - GitHub Actions support
# - Make
# - Go
# - Node.js
# - kubectx/kubens
# - Helm
# - AWS CLI
# - Terraform
# - Monitoring tools
# =========================================================

set -e

echo "========================================="
echo " SkillPulse DevOps Setup Starting..."
echo "========================================="

# ---------------------------------------------------------
# Update System
# ---------------------------------------------------------
sudo apt update && sudo apt upgrade -y

# ---------------------------------------------------------
# Essential Packages
# ---------------------------------------------------------
sudo apt install -y \
    curl \
    wget \
    git \
    unzip \
    zip \
    vim \
    nano \
    htop \
    jq \
    make \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# ---------------------------------------------------------
# Install Docker
# ---------------------------------------------------------
echo "Installing Docker..."

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo usermod -aG docker $USER

sudo systemctl enable docker
sudo systemctl start docker

# ---------------------------------------------------------
# Install kubectl
# ---------------------------------------------------------
echo "Installing kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# ---------------------------------------------------------
# Install Kind
# ---------------------------------------------------------
echo "Installing Kind..."

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# ---------------------------------------------------------
# Install Helm
# ---------------------------------------------------------
echo "Installing Helm..."

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ---------------------------------------------------------
# Install kubectx + kubens
# ---------------------------------------------------------
echo "Installing kubectx and kubens..."

sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx

sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# ---------------------------------------------------------
# Install AWS CLI
# ---------------------------------------------------------
echo "Installing AWS CLI..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "awscliv2.zip"

unzip awscliv2.zip
sudo ./aws/install

rm -rf aws awscliv2.zip

# ---------------------------------------------------------
# Install Terraform
# ---------------------------------------------------------
echo "Installing Terraform..."

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y terraform

# ---------------------------------------------------------
# Install Go
# ---------------------------------------------------------
echo "Installing Go..."

GO_VERSION="1.26.0"

wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

rm go${GO_VERSION}.linux-amd64.tar.gz

# ---------------------------------------------------------
# Install Node.js + npm
# ---------------------------------------------------------
echo "Installing Node.js..."

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

sudo apt install -y nodejs

# ---------------------------------------------------------
# Install k9s
# ---------------------------------------------------------
echo "Installing k9s..."

curl -sS https://webinstall.dev/k9s | bash

# ---------------------------------------------------------
# Install LazyDocker
# ---------------------------------------------------------
echo "Installing LazyDocker..."

curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# ---------------------------------------------------------
# Install Trivy
# ---------------------------------------------------------
echo "Installing Trivy..."

sudo apt install -y wget apt-transport-https gnupg lsb-release

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt update
sudo apt install -y trivy

# ---------------------------------------------------------
# Enable Kubernetes bash completion
# ---------------------------------------------------------
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

# ---------------------------------------------------------
# Create SkillPulse Kind Cluster
# ---------------------------------------------------------
echo "Creating Kind Cluster..."

cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8888
        protocol: TCP

  - role: worker
  - role: worker
EOF

kind create cluster --name skillpulse --config kind-config.yaml

# ---------------------------------------------------------
# Verify Installations
# ---------------------------------------------------------
echo "========================================="
echo " Installed Versions"
echo "========================================="

docker --version
kubectl version --client
kind --version
helm version
terraform version
go version
node -v
npm -v
aws --version

echo "========================================="
echo " Setup Completed Successfully"
echo "========================================="

echo ""
echo "NEXT STEPS:"
echo "1. Logout/Login or run: newgrp docker"
echo "2. Clone your repo"
echo "3. Run: make up"
echo "4. Open: http://localhost:8888"
echo ""
echo "Useful Commands:"
echo "kubectl get pods -A"
echo "kubectx"
echo "k9s"
echo "lazydocker"
echo ""
