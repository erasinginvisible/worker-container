#!/bin/bash

# Function to check if a command exists and is executable
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 is not installed or not in PATH"
        return 1
    fi
    return 0
}

# 1. Check for Docker Compose
echo "Checking required tools..."

check_command "sudo docker compose" || MISSING_TOOLS+="Docker Compose "

if ! ldconfig -p | grep -q libcuda.so; then
    echo "NVIDIA Container Toolkit is not installed or not properly configured"
    MISSING_TOOLS+="NVIDIA Container Toolkit "
fi

if [ -n "$MISSING_TOOLS" ]; then
    echo "The following tools are missing or not properly configured: $MISSING_TOOLS"
    echo "Please install or configure these tools before proceeding."
    exit 1
fi

echo "All required tools are installed and configured."

# 2. Stop and remove all containers, including those from the current docker-compose.yml
echo "Stopping and removing all containers..."
if [ -f docker-compose.yml ]; then
    echo "Stopping containers defined in docker-compose.yml..."
    sudo docker compose down --remove-orphans
    if [ $? -ne 0 ]; then
        echo "Error: Failed to stop and remove containers defined in docker-compose.yml."
        exit 1
    fi
fi

echo "Stopping and removing any remaining containers..."
sudo docker compose down --remove-orphans -v
if [ $? -eq 0 ]; then
    echo "All containers have been stopped and removed."
else
    echo "Error: Failed to stop and remove all containers."
    exit 1
fi

# 3. Start services with Docker Compose
echo "Starting services with Docker Compose..."
set -a
source .env
set +a
sudo docker compose up -d
if [ $? -eq 0 ]; then
    echo "Success: Docker Compose services are up and running."
else
    echo "Error: Failed to start Docker Compose services."
    exit 1
fi

echo "All operations completed successfully!"