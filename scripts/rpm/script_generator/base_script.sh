#!/bin/bash

# Logger Function       
log() {
  local message="$1"
  local type="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local color
  local endcolor="\033[0m"

  case "$type" in
    "info") color="\033[38;5;79m" ;;
    "success") color="\033[1;32m" ;;
    "error") color="\033[1;31m" ;;
    *) color="\033[1;34m" ;;
  esac

  echo -e "${color}${timestamp} - ${message}${endcolor}"
}

# Error handler function  
handle_error() {
  local exit_code=$1
  local error_message="$2"
  log "Error: $error_message (Exit Code: $exit_code)" "error"
  exit $exit_code
}

# Function to check for command availability
command_exists() {
  command -v "$1" &> /dev/null
}

# Check if we are on an RPM-based system
if ! [ -f /etc/redhat-release ] && ! grep -q "Amazon Linux" /etc/system-release 2>/dev/null; then
    handle_error 1 "This script is intended for RPM-based systems. Please run it on an RPM-based system."
fi

# Define Node.js version
NODE_VERSION="XX.x"

# Get system architecture
SYS_ARCH=$(uname -m)

# Validate system architecture
case "$SYS_ARCH" in
  aarch64|x86_64) log "Supported architecture: $SYS_ARCH" "info" ;;
  *) handle_error 1 "Unsupported architecture: $SYS_ARCH. Only aarch64 and x86_64 are supported." ;;
esac

# Repository content
REPO_CONTENT="[nodesource-nodejs]
name=Node.js Packages for Linux RPM based distros - $SYS_ARCH
baseurl=https://rpm.nodesource.com/pub_${NODE_VERSION}/nodistro/nodejs/$SYS_ARCH
priority=9
enabled=1
gpgcheck=1
gpgkey=https://rpm.nodesource.com/gpgkey/ns-operations-public.key
module_hotfixes=1"

echo "$REPO_CONTENT" | tee /etc/yum.repos.d/nodesource-nodistro.repo > /dev/null

# Check for availability of dnf or yum
if command_exists dnf; then
    log "dnf available, updating..." "info"
    dnf update -y
    log "Repository is configured and updated. Run 'dnf install nodejs -y' to complete the installation." "info"
    exit 0
elif command_exists yum; then
    log "yum available, updating..." "info"
    yum update -y
    log "Repository is configured and updated. Run 'yum install nodejs -y' to complete the installation." "info"
else
    handle_error 1 "Neither yum nor dnf package manager was found. Please update your system using your package manager."
fi
