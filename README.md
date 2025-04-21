# Custom Codabench Compute Worker

This repository contains the setup for building and running custom Docker images for Codabench compute workers, specifically tailored for GPU tasks using NVIDIA hardware. It is based on the official Codabench worker but includes specific configurations and build processes.

## What is Codabench?

[Codabench](https://github.com/codabench/codabench) is an open-source web-based platform that enables researchers, developers, and data scientists to collaborate, with the goal of advancing research fields where machine learning and advanced computation is used. Codabench helps to solve many common problems in the arena of data-oriented research through its online community where people can share worksheets and participate in competitions and benchmarks.

This repository provides the means to run the *compute worker* component of Codabench, which is responsible for executing the evaluation jobs submitted to the platform.

## Purpose of this Fork

This fork is configured to:

*   Build a custom compute worker Docker image (`johnding1996/codabench-erasinginvisible:latest`).
*   Utilize NVIDIA GPUs via the `Dockerfile.nvidia` and specific `docker-compose.yml` configurations.
*   Provide scripts for building the image (`build_container.sh`) and checking the setup (`check_setup.sh`).
*   Configure multiple worker instances in `docker-compose.yml`, each potentially assigned to a different GPU.

## Prerequisites

*   **Docker:** You need Docker installed and running. See [Docker installation guide](https://docs.docker.com/engine/install/).
*   **Docker Compose:** You need Docker Compose installed. See [Docker Compose installation guide](https://docs.docker.com/compose/install/).
*   **NVIDIA Container Toolkit:** If using the `Dockerfile.nvidia` and the provided `docker-compose.yml`, you need the NVIDIA Container Toolkit installed on the host machine to enable GPU access within the containers. See [NVIDIA Container Toolkit installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).
*   **NVIDIA Drivers:** Appropriate NVIDIA drivers must be installed on the host machine.
*   **Docker Hub Login:** The build script (`build_container.sh`) includes a step to push the image to Docker Hub (`johnding1996/codabench-erasinginvisible`). You will need to be logged into Docker (`docker login`) for this to succeed, or modify the script to remove the push step or target a different registry.

## Configuration

Configuration is primarily handled through the `.env` file. Create it if it doesn't exist (you can copy `.env.example` if available, though one wasn't listed in the provided files).

Key variables:

*   `BROKER_URL`: **Required**. The connection string for the Celery message broker provided by your Codabench instance. This tells the worker where to fetch jobs from. Example format: `pyamqp://<user>:<password>@<host>:<port>/<vhost>`
*   `HOST_DIRECTORY`: **Required**. An **absolute path** on the host machine where the worker will store submission data, bundles, and cache. This directory will be mounted into the worker containers. Ensure the directory exists and has appropriate permissions.
*   `BROKER_USE_SSL`: Set to `True` if the broker connection requires SSL. Comment out or set to `False` otherwise.
*   `CODALAB_IGNORE_CLEANUP_STEP`: Set to `True` to prevent the worker from cleaning up submission files after execution. Defaults to `False` if not set.

## Building the Custom Worker Image

The `build_container.sh` script automates the build process using `Dockerfile.nvidia`.

1.  **Review `build_container.sh`:** Check the Docker image name (`johnding1996/codabench-erasinginvisible:latest`) and the Docker Hub push command. Modify if necessary (e.g., if you don't want to push or want to use a different image name/registry).
2.  **Login to Docker (if pushing):** `docker login`
3.  **Run the build script:**
    ```bash
    sudo ./build_container.sh
    ```
    *Note: The script uses `sudo` for Docker commands. Adjust if you run Docker as a non-root user.*

Alternatively, you can build manually:

*   **NVIDIA GPU Image:**
    ```bash
    docker build -f Dockerfile.nvidia -t your-custom-image-name:latest .
    ```
*   **CPU Image (using `Dockerfile.ubuntu`):**
    ```bash
    docker build -f Dockerfile.ubuntu -t your-custom-cpu-image-name:latest .
    ```
    *Note: The provided `docker-compose.yml` is configured for the NVIDIA image and runtime. You would need to modify it significantly to use the CPU image.*

## Running the Workers

The `docker-compose.yml` file is configured to run multiple instances (8 by default) of the NVIDIA-based worker, assigning each to a specific GPU (GPU 0 to GPU 7).

1.  **Ensure Prerequisites are met:** Docker, Docker Compose, NVIDIA Container Toolkit, NVIDIA Drivers are installed and working.
2.  **Configure `.env`:** Make sure `BROKER_URL` and `HOST_DIRECTORY` are set correctly.
3.  **Review `docker-compose.yml`:**
    *   Verify the `image` name matches the one you built or want to use (e.g., `johnding1996/codabench-erasinginvisible:latest`).
    *   Adjust the number of worker services if needed.
    *   Modify the `device_ids` under `deploy.resources.reservations.devices` for each worker if you want to assign specific GPUs differently or if you have fewer/more than 8 GPUs. Ensure the specified device IDs exist on your host.
    *   Check the volume mount for `HOST_DIRECTORY`.
4.  **Start the workers:**
    ```bash
    docker compose up -d
    ```
5.  **Check worker logs:**
    ```bash
    docker compose logs -f worker1 # Or worker2, worker3, etc.
    ```
6.  **Stop the workers:**
    ```bash
    docker compose down
    ```

## Key Files

*   `compute_worker.py`: The main Python script for the Codabench worker logic.
*   `celery_config.py`: Configuration for the Celery task queue framework used by the worker.
*   `requirements.txt`: Python dependencies installed in the Docker image.
*   `Dockerfile.nvidia`: Dockerfile to build the worker image with NVIDIA GPU support (CUDA).
*   `Dockerfile.ubuntu`: Dockerfile to build a standard CPU-based worker image.
*   `docker-compose.yml`: Defines how to run the worker services (configured for multiple NVIDIA workers).
*   `build_container.sh`: Script to build and potentially push the NVIDIA Docker image.
*   `start_queue.sh`: Script likely used *inside* the container to start the Celery worker process (usually called by the Dockerfile's `CMD` or `ENTRYPOINT`).
*   `check_setup.sh`: Script to perform checks on the host environment.
*   `.env`: Environment variables for configuration (Broker URL, Host Directory, etc.).

## License

This code builds upon Codabench. The original Codabench code is licensed under the Apache License 2.0.

```
Copyright (c) 2020-2022, Université Paris-Saclay. This software is released under the Apache License 2.0 (the "License"); you may not use the software except in compliance with the License.

The text of the Apache License 2.0 can be found online at: http://www.opensource.org/licenses/apache2.0.php
```

Modifications within this repository are specific to this custom build setup.