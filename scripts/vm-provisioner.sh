#!/usr/bin/env bash

source "$(dirname "$0")"/libs/providers/firecracker.sh

set -o errexit
set -o pipefail
#set -o xtrace

NODE_PREFIX="$(basename -s .sh "$0")"
NODE_NUM=${NODE_NUM:-1}
PUB_KEY=${PUB_KEY:-$HOME/.ssh/id_rsa.pub}
PRI_KEY=${PRI_KEY:-$HOME/.ssh/id_rsa}

function help() {
  filename="$NODE_PREFIX.sh"

  cat <<EOF
Usage: $filename <setup | clean | ssh | info | env>

Setup nodes
❯ $filename setup <number of nodes>

Clean up nodes
❯ $filename clean

SSH the node
❯ $filename ssh <x-th node>

Show nodes info
❯ $filename info

Show the node environment variables
❯ $filename env <x-th node>

EOF
}

_check_args $# 1

case $1 in
setup | ssh | env)
  if [ -n "$2" ]; then
    NODE_NUM=$2
  fi

  $1 "$NODE_NUM"
  ;;

clean)
  $1
  ;;

info)
  $1
  ;;
*)
  _error "$1 command not found" help
  exit 1
  ;;
esac
