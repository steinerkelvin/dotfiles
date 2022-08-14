#!/bin/sh

# # Install on Arch Linux
# paru keyd

echo "Ensuring /etc/keyd/ directory exists..."
sudo mkdir -p /etc/keyd/

echo "Copying 'default.conf' keyd config file..."
sudo cp ./default.conf /etc/keyd/

echo "Enabling keyd service..."
sudo systemctl enable keyd

echo "Starting keyd service..."
sudo systemctl start  keyd

echo; echo "Service status:"; echo
sleep 0.5
systemctl status keyd
