#!/bin/bash

# Function to check if a directory exists, if not create it
check_and_create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created directory: $1"
    else
        echo "Directory already exists: $1"
    fi
}

# 1. Check current directory name
if [ "$(basename "$PWD")" != "worker-container" ]; then
    echo "Error: Please run this script inside the worker-container directory."
    exit 1
fi

# 2. Check and create cache and submissions directories
check_and_create_dir "../codabench/cache"
check_and_create_dir "../codabench/submissions"

# 3. Check if eval-program directory exists
if [ ! -d "../eval-program" ]; then
    echo "Error: The eval-program repository is not found."
    echo "Please clone the eval-program repository in the parent directory."
    exit 1
fi

echo "All checks completed successfully."