#!/bin/bash

# Usage: ./tunnel.sh <local_port> <server>

LOCAL_PORT=$1
SERVER=$2
USER=newuser
PASSWORD=jotham

if [ -z "$LOCAL_PORT" ] || [ -z "$SERVER" ]; then
    echo "Usage: $0 <local_port> <server>"
    exit 1
fi

# Generate a random remote port
REMOTE_PORT=$(shuf -i 20000-65000 -n 1)

# Establish SSH reverse tunnel and handle errors
echo "Establishing SSH tunnel from local port $LOCAL_PORT to remote port $REMOTE_PORT on server $SERVER..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -R $REMOTE_PORT:localhost:$LOCAL_PORT $USER@$SERVER -N &
SSH_PID=$!

sleep 2

if ps -p $SSH_PID > /dev/null; then
    echo "SSH tunnel established successfully."
    echo "Your application is accessible at http://new.ajotham.link:$REMOTE_PORT"
else
    echo "Failed to establish SSH tunnel."
    exit 1
fi

