#!/bin/bash
# Quick script to manage latest ubuntu docker containers
#   Useful for spinning up machines for development
# args:
#   name-of-machine
#   make|start|stop
#   make > sharedfolderhere:target
CONTAINER=$1
OP=$2
if [ "${OP}xx" == "makexx" ]; then
  # do an ifconfig to see which is your etherner interface and 
  # change it from eno1 below
  docker run \
    --name ${CONTAINER} \
    -e HOST_IP=$(ifconfig eno1 | awk '/ *ether /{print $2}') \
    -v $3 \
    -t -i \
    ubuntu /bin/bash
fi
if [ "${OP}xx" == "startxx" ]; then
  #check if it is already there
  FOUND=""
  FOUND=`docker ps -a -q --filter "name=$CONTAINER"`
  if [ "${FOUND}xx" != "xx" ]; then
    docker start $CONTAINER
    docker exec -it $FOUND /bin/bash
  else
    echo "Error: Could not find a container $CONTAINER"
  fi
fi
if [ "${OP}xx" == "stopxx" ]; then
  docker stop $CONTAINER
fi
