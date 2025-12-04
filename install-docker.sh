#!/bin/bash
###############################################################################
# Docker Installation Script for Ubuntu/Debian
# Compatible with Ubuntu 22.04 (based on your kernel version)
###############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root (use sudo)"
    exit 1
fi

log_info "Starting Docker installation..."

# Update package index
log_info "Updating package index..."
apt-get update -y

# Install prerequisites
log_info "Installing prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
log_info "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
log_info "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
log_info "Updating package index with Docker repository..."
apt-get update -y

# Install Docker Engine
log_info "Installing Docker Engine..."
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Start and enable Docker service
log_info "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Verify Docker installation
log_info "Verifying Docker installation..."
docker --version

# Add current user to docker group (if not root)
if [ -n "$SUDO_USER" ]; then
    log_info "Adding $SUDO_USER to docker group..."
    usermod -aG docker $SUDO_USER
    log_warn "User $SUDO_USER added to docker group. Log out and back in for this to take effect."
fi

# Test Docker installation
log_info "Testing Docker installation..."
docker run hello-world

log_info "Docker installation completed successfully!"
log_info "Docker version: $(docker --version)"
log_info "Docker Compose version: $(docker compose version)"

exit 0
