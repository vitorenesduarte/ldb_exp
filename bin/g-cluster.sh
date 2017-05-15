#!/usr/bin/env bash

NUM_NODES=3
NAME=lsim

if [ "$1" = "start" ]; then
  gcloud container clusters \
    create ${NAME} \
    --num-nodes=${NUM_NODES}

elif [ "$1" = "stop" ]; then
  gcloud container clusters \
    stop ${NAME}

fi
