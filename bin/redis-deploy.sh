#!/usr/bin/env bash

RUNNING=$(kubectl get pods |
    grep redis |
    grep Running)

if [ ! -z "$RUNNING" ]; then
    echo "[$(date +%T)] Redis already running. Exiting."
    exit
fi

# YAML file
FILE=/tmp/redis.yaml

cat <<EOF >${FILE}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  template:
    metadata:
      labels:
        tag: redis
    spec:
      containers:
      - name: redis
        image: redis
        imagePullPolicy: IfNotPresent
EOF

kubectl create -f ${FILE}

while [ $(kubectl get pods 2>/dev/null | grep redis | grep Running | wc -l) -eq 0 ]; do
    echo "redis is not up yet..."
    sleep 3
done
