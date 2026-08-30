terraform {
  required_version = ">= 1.0.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# ==============================================================================
# PROVIDER
# ==============================================================================

provider "docker" {
  host = "tcp://localhost:2375" #
}

# ==============================================================================
# 1. NETWORKS
# ==============================================================================

# Public network
# Used by the Frontend and Bastion.
# The Frontend is reachable from the host through port 8080.
resource "docker_network" "public_net" {
  name = "public-net"
}

# Private application network
# Used by Frontend, Backend and MariaDB.
resource "docker_network" "backend_net" {
  name = "backend-net"
}

# Private database/management network
# Used by MariaDB and Bastion.
resource "docker_network" "db_net" {
  name = "db-net"
}

# ==============================================================================
# 2. PERSISTENT STORAGE
# ==============================================================================

# Persistent storage for MariaDB.
#
# Database data is stored here instead of only inside the container.
# Therefore, recreating the MariaDB container does not automatically
# delete the database data.
resource "docker_volume" "mariadb_data" {
  name = "mariadb-data"
}

# ==============================================================================
# 3. DOCKER IMAGES
# ==============================================================================

# Frontend image
resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

# Temporary backend image
# Replace this later with the real backend application image.
resource "docker_image" "alpine" {
  name = "alpine:latest"
}

# Custom MariaDB + Ubuntu LTS image
resource "docker_image" "mariadb" {
  name = "zineb1112/mariadbubuntu1:latest"
}

# ==============================================================================
# 4. DATABASE
# ==============================================================================

resource "docker_container" "db" {

  # Required container name
  name = "MariaDBServer1"

  image = docker_image.mariadb.image_id

  # --------------------------------------------------------------------------
  # Persistent database storage
  # --------------------------------------------------------------------------

  volumes {
    volume_name    = docker_volume.mariadb_data.name
    container_path = "/var/lib/mysql"
  }

  # --------------------------------------------------------------------------
  # Database configuration
  # --------------------------------------------------------------------------

  env = [
    "MARIADB_ROOT_PASSWORD=RootPassword123!",
    "MARIADB_DATABASE=appdb"
  ]

  # --------------------------------------------------------------------------
  # Private networks
  # --------------------------------------------------------------------------

  networks_advanced {
    name = docker_network.backend_net.name
  }

  networks_advanced {
    name = docker_network.db_net.name
  }

  # IMPORTANT:
  #
  # There is NO ports section here.
  #
  # Therefore MariaDB is NOT directly accessible from the host.
  #
  # Backend → MariaDB
  # Bastion → MariaDB
  #
  # but:
  #
  # Host → MariaDB ❌
}

# ==============================================================================
# 5. BACKEND
# ==============================================================================

resource "docker_container" "backend" {

  name = "backend-api"

  # Temporary backend container.
  # Replace this image with the real backend application later.
  image = docker_image.alpine.image_id

  command = [
    "sh",
    "-c",
    "apk add --no-cache curl && sleep infinity"
  ]

  # Backend is only connected to the private application network.
  networks_advanced {
    name = docker_network.backend_net.name
  }

  # No public port.
  #
  # Frontend → Backend ✅
  # Backend → MariaDB ✅
  # Internet → Backend ❌
}

# ==============================================================================
# 6. FRONTEND
# ==============================================================================

resource "docker_container" "frontend" {

  name = "frontend-service"

  image = docker_image.nginx.image_id

  # --------------------------------------------------------------------------
  # Expose Frontend on port 8080
  #
  # Host:      localhost:8080
  # Container: port 80
  # --------------------------------------------------------------------------

  ports {
    internal = 80
    external = 8080
  }

  # --------------------------------------------------------------------------
  # Public network
  # --------------------------------------------------------------------------

  networks_advanced {
    name = docker_network.public_net.name
  }

  # --------------------------------------------------------------------------
  # Private application network
  #
  # This allows the Frontend to communicate with the Backend.
  # --------------------------------------------------------------------------

  networks_advanced {
    name = docker_network.backend_net.name
  }
}

# ==============================================================================
# 7. BASTION / DATABASE MANAGEMENT CONTAINER
# ==============================================================================

resource "docker_container" "bastion" {

  name = "bastion-bridge"

  image = docker_image.alpine.image_id

  # Install MariaDB client.
  #
  # The container stays alive so that you can execute backup commands
  # inside it.
  command = [
    "sh",
    "-c",
    "apk add --no-cache mariadb-client && sleep infinity"
  ]

  # --------------------------------------------------------------------------
  # Public network
  # --------------------------------------------------------------------------

  networks_advanced {
    name = docker_network.public_net.name
  }

  # --------------------------------------------------------------------------
  # Database network
  #
  # This gives the Bastion access to MariaDB without exposing MariaDB
  # directly to the host.
  # --------------------------------------------------------------------------

  networks_advanced {
    name = docker_network.db_net.name
  }

  # --------------------------------------------------------------------------
  # Backup directory
  #
  # The backup directory on the host is mounted into the Bastion at:
  #
  # /backups
  #
  # Create this directory before running Terraform:
  #
  # backups/
  #
  # Database backups created inside /backups will therefore be available
  # outside the MariaDB container.
  # --------------------------------------------------------------------------

  volumes {
    host_path      = "${path.cwd}/backups"
    container_path = "/backups"
  }
}