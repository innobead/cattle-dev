#!/usr/bin/env bash

CURDIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
export -n CURDIR
source "${CURDIR}/../libs/common.sh"

PROJECT_DIR=${PROJECT_DIR:-/home/davidko/github/rancher/rke2}
DAPPER_OPTS=${DAPPER_OPTS:-"DAPPER_MODE=bind GODEBUG=y"} # You can inject any ENV defined in DAPPER_ENV
MAIN_ARGS=${MAIN_ARGS:-server}
EXEC_FILE=${EXEC_FILE:-bin/rke2}

function build() {
  pushd "$PROJECT_DIR" &>/dev/null

  cmds=(
    "make .dapper"
    # "$DAPPER_OPTS ./.dapper -f Dockerfile --target dapper --keep make binary" # the binary built in container can not be used for remote debugging from the host
    "$DAPPER_OPTS ./scripts/build-binary"
  )

  for c in "${cmds[@]}"; do
    eval "$c"
  done

  popd &>/dev/null
}

function reset_remote_env() {
  :
}