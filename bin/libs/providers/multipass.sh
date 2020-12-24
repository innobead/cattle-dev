#!/usr/bin/env bash

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/../common.sh"

function setup() {
  if ! command -v multipass; then
    error "multipass not found. Please install by yourself"
  fi

  # can't create the file in /tmp, it will not be recognized by multipass
  trap 'rm -rf "$HOME"/cloud-init.yaml || true' EXIT ERR INT TERM
  cat <<EOF > "$HOME"/cloud-init.yaml
ssh_authorized_keys:
  - $(cat "$PUB_KEY")
EOF

  for ((i = 1; i <= NODE_NUM; i++)); do
    multipass launch \
      -n "$NODE_PREFIX"-"$i" \
      -c "$NODE_CPUS" \
      -m "$NODE_MEM" \
      -d "$NODE_DISK" \
      --cloud-init "$HOME"/cloud-init.yaml
  done
}

function clean() {
  mapfile -t nodes < <(multipass list | tail -n +2 | awk '{print $1}')

  for node in "${nodes[@]}"; do
    multipass delete -p "$node"
  done
}

function ssh_login() {
  node="$NODE_PREFIX"-"$1"
  host=$(multipass info "$node" --format json | jq -r ".info.\"$node\".ipv4[0]")
  ssh $SSH_OPTS ubuntu@"$host" -i "$PRI_KEY"
}

function node() {
  mapfile -t nodes < <(multipass list | tail -n +2 | awk '{print $1}')

  if [ ${#nodes[@]} -eq 0 ]; then
    error "No VMs provisioned"
  fi

  for node in "${nodes[@]}"; do
    echo "$node"
  done
}

function env() {
  node="$NODE_PREFIX"-"$1"
  host=$(multipass info "$node" --format json | jq -r ".info.$node.ipv4[0]" 2>/dev/null || error "VM not found")

  cat <<EOF
NAME=$NODE_PREFIX-$1
HOST=$host
PRI_KEY=$PRI_KEY
EOF
}
