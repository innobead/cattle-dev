#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

##### 1. Please add gcflags to add debug info in the built artifact
#--- a/scripts/package-cli
#+++ b/scripts/package-cli
#@@ -53,10 +53,8 @@ CMD_NAME=dist/artifacts/k3s${BIN_SUFFIX}
# LDFLAGS="
#     -X github.com/rancher/k3s/pkg/version.Version=$VERSION
#     -X github.com/rancher/k3s/pkg/version.GitCommit=${COMMIT:0:8}
#-    -w -s
# "
#-STATIC="-extldflags '-static'"
#-CGO_ENABLED=0 "${GO}" build -ldflags "$LDFLAGS $STATIC" -o ${CMD_NAME} ./cmd/k3s/main.go
#+CGO_ENABLED=0 "${GO}" build -ldflags "$LDFLAGS" -gcflags "all=-N -l" -o ${CMD_NAME} ./cmd/k3s/main.go
#

DAPPER_OPTS="DAPPER_MODE=bind DAPPER_ENV="""
cd "$(dirname "$0")"/../

pushd /home/davidko/github/k3s-io/k3s

cmds=(
  "$DAPPER_OPTS ./.dapper --keep download"
  "make deps"
  "$DAPPER_OPTS ./.dapper --keep generate"

  # Why use GO111MODULE=off in dapper given the project will be copied to GOPATH, this is because runc will not be built successfully w/o missing vendor folder
  # ref: https://github.com/k3s-io/k3s/blob/2ea6b16315c093d739c370f8f035ad3fa5eb5d11/vendor/github.com/opencontainers/runc/Makefile#L19-L19
  "$DAPPER_OPTS ./.dapper --keep build"
  "$DAPPER_OPTS ./.dapper --keep package-cli"
)

for c in "${cmds[@]}"; do
  eval "$c"
done

popd

./scripts/vm-provisioner.sh clean || true
./scripts/vm-provisioner.sh setup
host=$(./scripts/vm-provisioner.sh env | grep HOST | sed "s#HOST=##")

sleep 15
PROJECT_DIR=/home/davidko/github/k3s-io/k3s MAIN_ARGS="server" EXEC_FILE=dist/artifacts/k3s REMOTE_HOST=$host ./scripts/go-remote-debugger.sh remote_setup
PROJECT_DIR=/home/davidko/github/k3s-io/k3s MAIN_ARGS="server" EXEC_FILE=dist/artifacts/k3s REMOTE_HOST=$host ./scripts/go-remote-debugger.sh remote_debug
