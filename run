#!/bin/bash
#https://blog.yadutaf.fr/2017/09/10/running-a-graphical-app-in-a-docker-container-on-a-remote-server/

# Prepare target env
CONTAINER_HOME="test"
HOST_DOCKER_IP=172.17.0.1

# Create a directory for the socket
#mkdir -p display/socket

echo "" > Xauthority

# Get the DISPLAY slot
DISPLAY_NUMBER=$(echo $DISPLAY | cut -d. -f1 | cut -d: -f2)

# Extract current authentication cookie
AUTH_COOKIE=$(xauth list ${DISPLAY} | awk '{print $3}')

# Create the new X Authority file
xauth -f Xauthority add ${HOST_DOCKER_IP}:${DISPLAY_NUMBER} MIT-MAGIC-COOKIE-1 ${AUTH_COOKIE}

# Launch the container
docker run -it --rm \
  -e DISPLAY=${HOST_DOCKER_IP}:${DISPLAY_NUMBER} \
  -v ${PWD}/Xauthority:/home/${CONTAINER_HOME}/.Xauthority \
  docker-x-test /bin/bash
