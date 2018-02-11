#!/usr/bin/env bash

ENV_VARS=(
  IMAGE
  PULL_IMAGE
  LDB_MODE
  LDB_DRIVEN_MODE
  LDB_STATE_SYNC_INTERVAL
  LDB_REDUNDANT_DGROUPS
  LDB_DGROUP_BACK_PROPAGATION
  OVERLAY
  SIMULATION
  GMAP_SIMULATION_KEY_PERCENTAGE
  NODE_NUMBER
  NODE_EVENT_NUMBER
  BREAK_LINK
  CPU
)

for ENV_VAR in "${ENV_VARS[@]}"
do
  if [ -z "${!ENV_VAR}" ]; then
    echo ">>> ${ENV_VAR} is not configured; please export it."
    exit 1
  fi
done

echo "[$(date +%T)] Configuration: "
echo "    IMAGE: ${IMAGE}"
echo "    PULL_IMAGE: ${PULL_IMAGE}"
echo "    LDB_MODE: ${LDB_MODE}"
echo "    LDB_DRIVEN_MODE: ${LDB_DRIVEN_MODE}"
echo "    LDB_STATE_SYNC_INTERVAL: ${LDB_STATE_SYNC_INTERVAL}"
echo "    LDB_REDUNDANT_DGROUPS: ${LDB_REDUNDANT_DGROUPS}"
echo "    LDB_DGROUP_BACK_PROPAGATION: ${LDB_DGROUP_BACK_PROPAGATION}"
echo "    OVERLAY: ${OVERLAY}"
echo "    SIMULATION: ${SIMULATION}"
echo "    GMAP_SIMULATION_KEY_PERCENTAGE: ${GMAP_SIMULATION_KEY_PERCENTAGE}"
echo "    NODE_NUMBER: ${NODE_NUMBER}"
echo "    NODE_EVENT_NUMBER: ${NODE_EVENT_NUMBER}"
echo "    BREAK_LINK: ${BREAK_LINK}"
echo "    CPU: ${CPU}"

# ENV SETUP:
# Kubernetes server and auth token
APISERVER=$(bin/k8s_api_server.sh)
TOKEN=$(bin/k8s_api_token.sh)

ORCHESTRATION=kubernetes
METRICS_STORE=redis

# Evaluation timestamp: unix timestamp + random
R=$(echo $RANDOM + 10000 | bc)
TIMESTAMP=$(date +%s)${R}

# Port
PEER_PORT=6866

# DEPLOYMENT:
# Deployment names
RSG_NAME=rsg-${TIMESTAMP}
LSIM_NAME=lsim-${TIMESTAMP}

# YAML file
FILE=/tmp/${TIMESTAMP}.yaml

cat <<EOF > "${FILE}"
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: "${RSG_NAME}"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        timestamp: "${TIMESTAMP}"
        tag: rsg
    spec:
      containers:
      - name: "${RSG_NAME}"
        image: "${IMAGE}"
        imagePullPolicy: "${PULL_IMAGE}"
        env:
        - name: ORCHESTRATION
          value: "${ORCHESTRATION}"
        - name: METRICS_STORE
          value: "${METRICS_STORE}"
        - name: IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: APISERVER
          value: "${APISERVER}"
        - name: TOKEN
          value: "${TOKEN}"
        - name: TIMESTAMP
          value: "${TIMESTAMP}"
        - name: LDB_MODE
          value: "${LDB_MODE}"
        - name: LDB_DRIVEN_MODE
          value: "${LDB_DRIVEN_MODE}"
        - name: LDB_STATE_SYNC_INTERVAL
          value: "${LDB_STATE_SYNC_INTERVAL}"
        - name: LDB_REDUNDANT_DGROUPS
          value: "${LDB_REDUNDANT_DGROUPS}"
        - name: LDB_DGROUP_BACK_PROPAGATION
          value: "${LDB_DGROUP_BACK_PROPAGATION}"
        - name: OVERLAY
          value: "${OVERLAY}"
        - name: SIMULATION
          value: "${SIMULATION}"
        - name: GMAP_SIMULATION_KEY_PERCENTAGE
          value: "${GMAP_SIMULATION_KEY_PERCENTAGE}"
        - name: NODE_NUMBER
          value: "${NODE_NUMBER}"
        - name: NODE_EVENT_NUMBER
          value: "${NODE_EVENT_NUMBER}"
        - name: BREAK_LINK
          value: "${BREAK_LINK}"
        - name: RSG
          value: "true"
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: "${LSIM_NAME}"
spec:
  replicas: ${NODE_NUMBER}
  template:
    metadata:
# Enabling Unsafe Sysctls:
# - Docs: https://kubernetes.io/docs/concepts/cluster-administration/sysctl-cluster/#safe-vs-unsafe-sysctls
# - PR:   https://github.com/kubernetes/kubernetes/pull/26057/files?short_path=8dc23ab#diff-8dc23ab258695ee42154d4d1238c36ef
# - Help: http://www.ehowstuff.com/configure-linux-tcp-keepalive-setting/
#      annotations:
#        security.alpha.kubernetes.io/unsafe-sysctls: net.ipv4.tcp_keepalive_time=10,net.ipv4.tcp_keepalive_intvl=5,net.ipv4.tcp_keepalive_probes=1
      labels:
        timestamp: "${TIMESTAMP}"
        tag: lsim
    spec:
      containers:
      - name: "${LSIM_NAME}"
        image: "${IMAGE}"
        imagePullPolicy: "${PULL_IMAGE}"
        resources:
          requests:
            cpu: "${CPU}"
        securityContext:
          privileged: true
        env:
        - name: ORCHESTRATION
          value: "${ORCHESTRATION}"
        - name: METRICS_STORE
          value: "${METRICS_STORE}"
        - name: IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: PEER_PORT
          value: "${PEER_PORT}"
        - name: APISERVER
          value: "${APISERVER}"
        - name: TOKEN
          value: "${TOKEN}"
        - name: TIMESTAMP
          value: "${TIMESTAMP}"
        - name: LDB_MODE
          value: "${LDB_MODE}"
        - name: LDB_DRIVEN_MODE
          value: "${LDB_DRIVEN_MODE}"
        - name: LDB_STATE_SYNC_INTERVAL
          value: "${LDB_STATE_SYNC_INTERVAL}"
        - name: LDB_REDUNDANT_DGROUPS
          value: "${LDB_REDUNDANT_DGROUPS}"
        - name: LDB_DGROUP_BACK_PROPAGATION
          value: "${LDB_DGROUP_BACK_PROPAGATION}"
        - name: LDB_METRICS
          value: "true"
        - name: OVERLAY
          value: "${OVERLAY}"
        - name: SIMULATION
          value: "${SIMULATION}"
        - name: GMAP_SIMULATION_KEY_PERCENTAGE
          value: "${GMAP_SIMULATION_KEY_PERCENTAGE}"
        - name: NODE_NUMBER
          value: "${NODE_NUMBER}"
        - name: NODE_EVENT_NUMBER
          value: "${NODE_EVENT_NUMBER}"
        - name: BREAK_LINK
          value: "${BREAK_LINK}"
        - name: RSG
          value: "false"
EOF

kubectl create -f "${FILE}"

while [ $(kubectl get pods -l timestamp=${TIMESTAMP} 2> /dev/null | wc -l) -gt 0 ]; do
    sleep 1
done

echo "[$(date +%T)] Done!"
