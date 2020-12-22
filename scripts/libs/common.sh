#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/vars.sh")"

function _check_args() {
  if [ "$1" -ge "$2" ]; then
    return
  fi

  _error "Requires $2 arguments" help
}

function _error() {
  echo "[ERROR] $1" >/dev/stderr
  if [ -n "$2" ]; then
    $2
  fi
  exit 1
}

function _install_huber() {
  if [[ ! $(command -v huber) ]] || [ "$FORCE_INSTALL_PRE" == "true" ]; then
    curl -sfSL https://raw.githubusercontent.com/innobead/huber/master/hack/install.sh | bash
    source "$HOME"/.bashrc
  fi
}
