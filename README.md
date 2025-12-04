# Docker Auto-Start Automation Scripts

This repository contains automation scripts to install Docker and configure a Docker application to run automatically on Linux boot.

## 📋 Overview

These scripts are designed for **Ubuntu/Debian** systems (tested on Ubuntu 22.04 with kernel 5.15.0-43-generic) and will:
1. Install Docker Engine and Docker Compose
2. Configure a Docker application to start automatically on boot
3. Set up systemd service for reliable application lifecycle management

## 📁 Files

- **`install-docker.sh`** - Installs Docker Engine on Ubuntu/Debian systems
- **`docker-app-start.sh`** - Manages your Docker application lifecycle
- **`docker-app.service`** - Systemd service unit file for auto-start
- **`setup.sh`** - Master setup script that orchestrates everything

## 🚀 Quick Start

### 1. Transfer files to your Linux VM

```bash
# Copy all files to your Linux VM
scp *.sh *.service user@your-vm-ip:/home/user/docker-setup/
```

### 2. Configure your application

Edit `docker-app-start.sh` and customize these variables:

```bash
APP_NAME="my-app"                    # Your application name
DOCKER_IMAGE="nginx:latest"          # Your Docker image
PORT_MAPPINGS="-p 8080:80"          # Port mappings
VOLUME_MAPPINGS=""                   # Volume mounts (optional)
ENV_VARS=""                          # Environment variables (optional)
```

### 3. Run the setup

```bash
# Make setup script executable
chmod +x setup.sh

# Run as root
sudo ./setup.sh
```

That's it! Your Docker application will now start automatically on every boot.

## 🔧 Manual Installation

If you prefer to run each step manually:

### Step 1: Install Docker

```bash
chmod +x install-docker.sh
sudo ./install-docker.sh
```

### Step 2: Install the application startup script

```bash
sudo cp docker-app-start.sh /usr/local/bin/docker-app-start.sh
sudo chmod +x /usr/local/bin/docker-app-start.sh
```

### Step 3: Install and enable the systemd service

```bash
sudo cp docker-app.service /etc/systemd/system/docker-app.service
sudo systemctl daemon-reload
sudo systemctl enable docker-app.service
sudo systemctl start docker-app.service
```

## 📊 Managing the Service

### Check service status
```bash
sudo systemctl status docker-app.service
```

### View logs
```bash
sudo journalctl -u docker-app.service -f
```

### Restart the service
```bash
sudo systemctl restart docker-app.service
```

### Stop the service
```bash
sudo systemctl stop docker-app.service
```

### Disable auto-start
```bash
sudo systemctl disable docker-app.service
```

## 🎯 Customization Examples

### Example 1: Running a custom web application

```bash
APP_NAME="webapp"
DOCKER_IMAGE="myregistry/webapp:latest"
PORT_MAPPINGS="-p 80:8080 -p 443:8443"
VOLUME_MAPPINGS="-v /data/webapp:/app/data"
ENV_VARS="-e DATABASE_URL=postgres://db:5432 -e ENV=production"
```

### Example 2: Running multiple containers with Docker Compose

Replace the `start_application()` function in `docker-app-start.sh`:

```bash
start_application() {
    log_info "Starting application with Docker Compose"
    cd /path/to/docker-compose-directory
    docker compose up -d
}
```

### Example 3: Running a database container

```bash
APP_NAME="postgres-db"
DOCKER_IMAGE="postgres:15"
PORT_MAPPINGS="-p 5432:5432"
VOLUME_MAPPINGS="-v /var/lib/postgresql/data:/var/lib/postgresql/data"
ENV_VARS="-e POSTGRES_PASSWORD=secure_password -e POSTGRES_DB=myapp"
```

## 🔍 Troubleshooting

### Service fails to start

Check the logs:
```bash
sudo journalctl -u docker-app.service -n 50 --no-pager
```

### Docker daemon not ready

The script waits up to 60 seconds for Docker to be ready. If it still fails:
```bash
sudo systemctl status docker
sudo systemctl restart docker
```

### Container keeps restarting

Check container logs:
```bash
docker logs <container-name>
```

### Permission issues

Make sure the scripts are executable and owned by root:
```bash
sudo chown root:root /usr/local/bin/docker-app-start.sh
sudo chmod 755 /usr/local/bin/docker-app-start.sh
```

## 🔐 Security Considerations

1. **Secrets Management**: Don't hardcode sensitive data in scripts. Use Docker secrets or environment files.
2. **Network Security**: Configure firewall rules for exposed ports.
3. **Image Security**: Use specific image tags instead of `latest` in production.
4. **User Permissions**: Run containers as non-root users when possible.

## 📝 System Requirements

- **OS**: Ubuntu 20.04+ or Debian 10+
- **Architecture**: x86_64 (amd64)
- **Privileges**: Root access (sudo)
- **Network**: Internet connection for initial Docker installation

## 🛠️ Advanced Configuration

### Using Docker Compose

Create a `docker-compose.yml` file and modify `docker-app-start.sh`:

```bash
# In the start_application() function:
start_application() {
    log_info "Starting application with Docker Compose"
    cd /opt/my-app
    docker compose up -d
}
```

### Adding health checks

Add to `docker-app.service`:

```ini
[Service]
ExecStartPost=/bin/sleep 10
ExecStartPost=/usr/bin/docker exec my-app-container curl -f http://localhost/health || exit 1
```

### Email notifications on failure

Install `mailutils` and add to `docker-app.service`:

```ini
[Service]
OnFailure=email-notify@%n.service
```

## 📄 License

These scripts are provided as-is for educational and production use.

## 🤝 Contributing

Feel free to customize these scripts for your specific use case.
