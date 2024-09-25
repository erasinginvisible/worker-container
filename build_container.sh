#!/bin/bash

# Function to check if Docker is logged in
check_docker_login() {
    if ! sudo docker info 2>/dev/null | grep -q "Username"; then
        echo "Error: You are not logged in to Docker."
        echo "Please log in to Docker using: docker login"
        exit 1
    fi
}

# Check Docker login status
echo "Checking Docker login status..."
check_docker_login

echo "Docker is logged in. Proceeding with build and push..."

echo "Building the worker container..."
sudo docker build --no-cache -f Dockerfile.nvidia -t johnding1996/codabench-erasinginvisible:latest ./

# echo "Pushing the worker container to docker hub..."
sudo docker push johnding1996/codabench-erasinginvisible --all-tags

echo "Build and push completed successfully."