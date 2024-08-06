#!/bin/bash

# Usage: ./tunnel.sh <local_port>

LOCAL_PORT=$1
SERVER=52.90.23.87
USER=newuser
PASSWORD=jotham
SUBDOMAIN=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)

if [ -z "$LOCAL_PORT" ]; then
    echo "Usage: $0 <local_port>"
    exit 1
fi

# Function to stop existing SSH tunnels
stop_tunnel() {
    echo "Stopping existing SSH tunnels..."
    pkill -f "ssh -R"
    echo "Existing SSH tunnels stopped."
}

# Stop existing tunnels before starting a new one
stop_tunnel

# Generate a random remote port
REMOTE_PORT=$(shuf -i 20000-65000 -n 1)

# Establish SSH reverse tunnel and handle errors
echo "Establishing new SSH tunnel..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -R $REMOTE_PORT:localhost:$LOCAL_PORT $USER@$SERVER -N &
SSH_PID=$!

sleep 2

if ps -p $SSH_PID > /dev/null; then
    echo "SSH tunnel established successfully."
    echo "Your application is accessible at http://$SUBDOMAIN.new.ajotham.link:$REMOTE_PORT"
else
    echo "Failed to establish SSH tunnel."
    exit 1
fi

