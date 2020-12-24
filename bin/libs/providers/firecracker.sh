#!/usr/bin/env bash

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/../common.sh"

function setup() {
  _install_tools

  for ((i = 1; i <= NODE_NUM; i++)); do
    sudo ignite run ghcr.io/innobead/kubefire-ubuntu:20.04 \
      --name "$NODE_PREFIX"-"$i" \
      --kernel-image ghcr.io/innobead/kubefire-ignite-kernel:4.19.125-amd64 \
      --cpus "$NODE_CPUS" \
      --memory "$NODE_MEM"B \
      --size "$NODE_DISK"B \
      --ssh="$PUB_KEY"
  done
}

function clean() {
  mapfile -t nodes < <(sudo ignite ps -a -t "{{.Name}}" | grep "$NODE_PREFIX")

  for node in "${nodes[@]}"; do
    sudo ignite rm "$node" --force
  done
}

function ssh_login() {
  sudo ignite ssh "$NODE_PREFIX"-"$1" -i "$PRI_KEY"
}

function node() {
  mapfile -t nodes < <(sudo ignite ps -a -t "{{.Name}}" | grep "$NODE_PREFIX")

  if [ ${#nodes[@]} -eq 0 ]; then
      error "No VMs provisioned"
  fi

  for node in "${nodes[@]}"; do
    echo "$node"
  done
}

function env() {
  host=$(sudo ignite inspect vm "$NODE_PREFIX"-"$1" | jq -r '.status.network.ipAddresses[0]' 2>/dev/null || error "VM not found")

  cat <<EOF
NAME=$NODE_PREFIX-$1
HOST=$host
PRI_KEY=$PRI_KEY
EOF
}

function _install_tools() {
  install_huber

  if [[ ! $(command -v kubefire) ]] || [ "$FORCE_INSTALL" == "true" ]; then
    huber install kubefire
  elif [ "$FORCE_INSTALL" == "true" ]; then
    huber update kubefire
  fi

  if kubefire info | grep expected; then
    kubefire install
  fi
}

