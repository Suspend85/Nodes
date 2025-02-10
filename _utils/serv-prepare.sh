#!/bin/bash

# Colors for output
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Function to print a separator line
print_separator() {
    echo -e "${GREEN}###########################################################################################${NC}"
}

# Function to print a header message
print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Start script
cd $HOME

# Update and upgrade system
print_separator
print_header "Updating and upgrading server..."
echo '' && sleep 1
sudo apt update && sudo apt upgrade -y

# Install essential software
print_separator
print_header "Installing dependencies..."
echo '' && sleep 1
sudo apt install -y \
    curl \
    mc \
    git \
    jq \
    screen \
    lz4 \
    build-essential \
    htop \
    zip \
    unzip \
    wget \
    rsync \
    snapd

# Install yq using snap
print_separator
print_header "Installing yq..."
echo '' && sleep 1
sudo snap install yq

# Install and configure Fail2Ban
print_separator
print_header "Configuring Fail2Ban..."
echo '' && sleep 1
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Clean up
print_separator
print_header "Cleaning up..."
echo '' && sleep 1
sudo apt autoremove -y
sudo apt clean -y

# Final message
print_separator
echo -e "${GREEN}Server setup completed successfully!${NC}"
echo -e "${BLUE}Please reboot the server to apply all changes.${NC}"
print_separator
