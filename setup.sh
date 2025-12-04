#!/bin/bash
###############################################################################
# Setup Script for Docker Auto-Start
# This script installs and configures Docker to run your application on boot
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root (use sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info "Docker Application Auto-Start Setup"
log_info "====================================="

# Step 1: Install Docker
log_step "Step 1: Installing Docker..."
if ! command -v docker &> /dev/null; then
    if [ -f "$SCRIPT_DIR/install-docker.sh" ]; then
        chmod +x "$SCRIPT_DIR/install-docker.sh"
        "$SCRIPT_DIR/install-docker.sh"
    else
        log_error "install-docker.sh not found!"
        exit 1
    fi
else
    log_info "Docker is already installed: $(docker --version)"
fi

# Step 2: Install application startup script
log_step "Step 2: Installing application startup script..."
if [ -f "$SCRIPT_DIR/docker-app-start.sh" ]; then
    cp "$SCRIPT_DIR/docker-app-start.sh" /usr/local/bin/docker-app-start.sh
    chmod +x /usr/local/bin/docker-app-start.sh
    log_info "Application startup script installed to /usr/local/bin/docker-app-start.sh"
else
    log_error "docker-app-start.sh not found!"
    exit 1
fi

# Step 3: Install systemd service
log_step "Step 3: Installing systemd service..."
if [ -f "$SCRIPT_DIR/docker-app.service" ]; then
    cp "$SCRIPT_DIR/docker-app.service" /etc/systemd/system/docker-app.service
    log_info "Systemd service installed to /etc/systemd/system/docker-app.service"
else
    log_error "docker-app.service not found!"
    exit 1
fi

# Step 4: Reload systemd and enable service
log_step "Step 4: Enabling service to start on boot..."
systemctl daemon-reload
systemctl enable docker-app.service
log_info "Service enabled successfully"

# Step 5: Start the service now
log_step "Step 5: Starting the service..."
if systemctl start docker-app.service; then
    log_info "Service started successfully"
else
    log_warn "Service failed to start. Check logs with: journalctl -u docker-app.service -f"
fi

# Display status
log_info ""
log_info "Setup completed successfully!"
log_info "====================================="
log_info ""
log_info "Service status:"
systemctl status docker-app.service --no-pager || true
log_info ""
log_info "Useful commands:"
log_info "  - Check service status: sudo systemctl status docker-app.service"
log_info "  - View logs: sudo journalctl -u docker-app.service -f"
log_info "  - Restart service: sudo systemctl restart docker-app.service"
log_info "  - Stop service: sudo systemctl stop docker-app.service"
log_info "  - Disable auto-start: sudo systemctl disable docker-app.service"
log_info ""
log_warn "IMPORTANT: Edit /usr/local/bin/docker-app-start.sh to configure your Docker image and settings"

exit 0
