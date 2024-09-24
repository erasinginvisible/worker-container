#!/bin/bash

# Function to check if Docker is logged in
check_docker_login() {
    if ! docker info 2>/dev/null | grep -q "Username"; then
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
docker build --no-cache -f Dockerfile.compute_worker_gpu -t johnding1996/codabench-erasinginvisible:latest ./

echo "Pushing the worker container to docker hub..."
docker push johnding1996/codabench-erasinginvisible --all-tags

echo "Build and push completed successfully."