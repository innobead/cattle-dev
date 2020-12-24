#!/usr/bin/env bash

CURDIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
export -n CURDIR
source "${CURDIR}/../libs/common.sh"

PROJECT_DIR=${PROJECT_DIR:-/home/davidko/github/k3s-io/k3s}
DAPPER_OPTS=${DAPPER_OPTS:-"DAPPER_MODE=bind"} # You can inject any ENV defined in DAPPER_ENV
MAIN_ARGS=${MAIN_ARGS:-server}
EXEC_FILE=${EXEC_FILE:-dist/artifacts/k3s}

function build() {
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

  pushd "$PROJECT_DIR" &>/dev/null

  cmds=(
    "make .dapper"
    "$DAPPER_OPTS ./.dapper --keep download"
    "make deps"
    "$DAPPER_OPTS ./.dapper --keep generate"

    # Why use GO111MODULE=off in dapper given the project will be copied to GOPATH, this is because runc will not be built successfully w/o missing vendor folder
    # ref: https://github.com/k3s-io/k3s/blob/2ea6b16315c093d739c370f8f035ad3fa5eb5d11/vendor/github.com/opencontainers/runc/Makefile#L19-L19
    "$DAPPER_OPTS ./.dapper --keep build"
    #  "$DAPPER_OPTS ./.dapper --keep package-cli"
    "$DAPPER_OPTS ./scripts/package-cli"
  )

  for c in "${cmds[@]}"; do
    eval "$c"
  done

  popd &>/dev/null
}

function reset_remote_env() {
  :
}