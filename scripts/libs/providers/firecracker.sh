#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/../common.sh")"

function setup() {
  # install prerequisites
  _install_firecracker

  for ((i = 1; i <= NODE_NUM; i++)); do
    sudo ignite run ghcr.io/innobead/kubefire-ubuntu:20.04 \
      --name "$NODE_PREFIX"-"$i" \
      --kernel-image ghcr.io/innobead/kubefire-ignite-kernel:5.4.43-amd64 \
      --cpus 1 \
      --memory 512MB \
      --ssh="$PUB_KEY"
  done
}

function clean() {
  mapfile -t nodes < <(sudo ignite ps -t "{{.Name}}" | grep "$NODE_PREFIX")

  for node in "${nodes[@]}"; do
    sudo ignite rm "$node" --force
  done
}

function ssh() {
  sudo ignite ssh "$NODE_PREFIX"-"$1" -i "$PRI_KEY"
}

function info() {
  mapfile -t nodes < <(sudo ignite ps -t "{{.Name}}" | grep "$NODE_PREFIX")

  if [ ${#nodes[@]} -eq 0 ]; then
      _error "No VMs provisioned"
  fi

  for node in "${nodes[@]}"; do
    echo "$node"
  done
}

function env() {
  host=$(sudo ignite inspect vm "$NODE_PREFIX"-"$1" | jq -r '.status.network.ipAddresses[0]' 2>/dev/null || _error "VM not found")

  cat <<EOF
NAME=$NODE_PREFIX-$1
HOST=$host
PRI_KEY=$PRI_KEY
EOF
}

function _install_firecracker() {
  _install_huber

  if [[ ! $(command -v kubefire) ]] || [ "$FORCE_INSTALL_PRE" == "true" ]; then
    huber install kubefire
  elif [ "$FORCE_INSTALL_PRE" == "true" ]; then
    huber update kubefire
  fi

  if kubefire info | grep expected; then
    kubefire install
  fi
}

