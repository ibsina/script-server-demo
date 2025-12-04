#!/bin/bash
###############################################################################
# Docker Application Startup Script
# This script manages your Docker application lifecycle
###############################################################################

set -e

# Configuration - CUSTOMIZE THESE VARIABLES
APP_NAME="my-app"
DOCKER_IMAGE="nginx:latest"  # Change to your Docker image
CONTAINER_NAME="${APP_NAME}-container"
DOCKER_NETWORK="app-network"

# Port mappings (format: HOST_PORT:CONTAINER_PORT)
PORT_MAPPINGS="-p 8080:80"  # Change as needed

# Volume mappings (format: HOST_PATH:CONTAINER_PATH)
# VOLUME_MAPPINGS="-v /host/path:/container/path"
VOLUME_MAPPINGS=""

# Environment variables
# ENV_VARS="-e VAR1=value1 -e VAR2=value2"
ENV_VARS=""

# Additional Docker run options
EXTRA_OPTS="--restart unless-stopped"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Wait for Docker daemon to be ready
wait_for_docker() {
    log_info "Waiting for Docker daemon to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker info >/dev/null 2>&1; then
            log_info "Docker daemon is ready"
            return 0
        fi
        log_info "Waiting for Docker... (attempt $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "Docker daemon failed to start within timeout"
    return 1
}

# Create Docker network if it doesn't exist
create_network() {
    if ! docker network ls | grep -q "$DOCKER_NETWORK"; then
        log_info "Creating Docker network: $DOCKER_NETWORK"
        docker network create "$DOCKER_NETWORK"
    else
        log_info "Docker network $DOCKER_NETWORK already exists"
    fi
}

# Stop and remove existing container
cleanup_existing() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_info "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" || true
        log_info "Removing existing container: $CONTAINER_NAME"
        docker rm "$CONTAINER_NAME" || true
    fi
}

# Pull latest image
pull_image() {
    log_info "Pulling Docker image: $DOCKER_IMAGE"
    docker pull "$DOCKER_IMAGE"
}

# Start the application
start_application() {
    log_info "Starting application container: $CONTAINER_NAME"
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        --network "$DOCKER_NETWORK" \
        $PORT_MAPPINGS \
        $VOLUME_MAPPINGS \
        $ENV_VARS \
        $EXTRA_OPTS \
        "$DOCKER_IMAGE"
    
    log_info "Container started successfully"
    log_info "Container ID: $(docker ps --filter name=$CONTAINER_NAME --format '{{.ID}}')"
}

# Main execution
main() {
    log_info "Starting Docker application: $APP_NAME"
    
    # Wait for Docker to be ready
    wait_for_docker || exit 1
    
    # Create network
    create_network
    
    # Cleanup existing container
    cleanup_existing
    
    # Pull latest image
    pull_image
    
    # Start application
    start_application
    
    # Show container status
    log_info "Application status:"
    docker ps --filter name=$CONTAINER_NAME
    
    log_info "Application $APP_NAME started successfully!"
}

# Run main function
main
