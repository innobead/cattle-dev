#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

PROJECT_DIR=${PROJECT_DIR:-/home/davidko/github/rancher/rke2}
DAPPER_OPTS=${DAPPER_OPTS:-"DAPPER_MODE=bind GODEBUG=y"} # You can inject any ENV defined in DAPPER_ENV
MAIN_ARGS=${MAIN_ARGS:-server}
EXEC_FILE=${EXEC_FILE:-bin/rke2}

cd "$(dirname "$0")"/../

pushd "$PROJECT_DIR"

cmds=(
  "make .dapper"
  # "$DAPPER_OPTS ./.dapper -f Dockerfile --target dapper --keep make binary" # the binary built in container can not be used for remote debugging from the host
  "$DAPPER_OPTS ./scripts/build-binary"
)

for c in "${cmds[@]}"; do
  eval "$c"
done

popd

./scripts/vm.sh clean || true
./scripts/vm.sh setup
host=$(./scripts/vm.sh env | grep HOST | sed "s#HOST=##")

sleep 15
PROJECT_DIR=$PROJECT_DIR MAIN_ARGS=$MAIN_ARGS EXEC_FILE=$EXEC_FILE REMOTE_HOST=$host ./scripts/go-remote-debug.sh remote_setup
PROJECT_DIR=$PROJECT_DIR MAIN_ARGS=$MAIN_ARGS EXEC_FILE=$EXEC_FILE REMOTE_HOST=$host ./scripts/go-remote-debug.sh remote_debug
