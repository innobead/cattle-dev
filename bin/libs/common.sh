#!/usr/bin/env bash

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/vars.sh"

set -o errexit
set -o pipefail

function check_args() {
  if [ "$1" -ge "$2" ]; then
    return
  fi

  error "Requires $2 arguments" help
}

function error() {
  echo "[ERROR] $1" >/dev/stderr
  if [ -n "$2" ]; then
    $2
  fi
  exit 1
}

function install_huber() {
  if [[ ! $(command -v huber) ]] || [ "$FORCE_INSTALL" == "true" ]; then
    curl -sfSL https://raw.githubusercontent.com/innobead/huber/master/hack/install.sh | bash
    source "$HOME"/.bashrc
  fi
}

function get_pkgmgr() {
  if command -v zypper &>/dev/null; then
    echo "zypper"
  elif command -v apt &>/dev/null; then
    echo "apt"
  else
    echo "unknown"
  fi
}

function enable_trace() {
  set -o xtrace
}

if [ -n "$DEBUG" ]; then
  enable_trace
fi
