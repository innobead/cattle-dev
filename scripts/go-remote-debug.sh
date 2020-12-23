#!/usr/bin/env bash

source "$(dirname "$0")"/libs/common.sh

set -o errexit
set -o pipefail
#set -o xtrace

FILENAME="$(basename -s .sh "$0")"

GO_VERSION=${GO_VERSION:-go1.15.6}
REMOTE_USER=${REMOTE_USER:-root}
REMOTE_HOST=${REMOTE_HOST:?}
REMOTE_DEBUG_PORT=${REMOTE_DEBUG_PORT:-2345}
PRI_KEY=${PRI_KEY:-$HOME/.ssh/id_rsa}
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
WORKPLACE=${WORKPLACE:-/tmp/$FILENAME}

PROJECT_DIR=${PROJECT_DIR:?}
MAIN_FILE=${MAIN_FILE:-main.go}
MAIN_ARGS=${MAIN_ARGS:-}
EXEC_FILE=${EXEC_FILE:-$(basename -s .go "$MAIN_FILE")}
BUILD_CMD=${BUILD_CMD:-go list -m all || true; go build -gcflags \"all=-N -l\" -o $EXEC_FILE $MAIN_FILE}

REMOTE_EXEC_FILE="$(basename "$EXEC_FILE")"

function debug() {
  build
  remote_setup
  _remote_run
}

function build() {
  pushd "$PROJECT_DIR"
  eval "$BUILD_CMD"
  popd
}

function remote_setup() {
  # shellcheck disable=SC2064
  trap "rm -rf /$WORKPLACE/setup.sh || true" EXIT ERR INT TERM
  pushd "$WORKPLACE"

  cp "$PROJECT_DIR/$EXEC_FILE" .

  _create_setup_script setup.sh
  chmod +x setup.sh

  files=(
    "$REMOTE_EXEC_FILE"
    setup.sh
  )

  for f in "${files[@]}"; do
    # shellcheck disable=SC2086
    scp $SSH_OPTS -i "$PRI_KEY" "$WORKPLACE/$f" "$REMOTE_USER"@"$REMOTE_HOST":~/
  done

  cmds=(
    "source ~/.bashrc && \$HOME/setup.sh"
  )
  _remote_run "${cmds[@]}"

  popd
}

function remote_debug() {
  cmds=(
    "source ~/.bashrc && dlv --listen=:"$REMOTE_DEBUG_PORT" --headless=true --api-version=2 --accept-multiclient --check-go-version=false exec \$HOME/"$REMOTE_EXEC_FILE" $MAIN_ARGS"
  )
  _remote_run "${cmds[@]}"
}

function _create_setup_script() {
  if [[ ! $(command -v apt) ]] || [[ ! $(command -v zypper) ]]; then
    _error "Unsupported OS to setup remote host"
  fi

  cat <<EOF >"$1"
#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o xtrace

trap "rm -rf $GO_VERSION.linux-amd64.tar.gz || true" EXIT ERR INT TERM

apt update || zypper refresh

if ! command -v git; then
  apt install -y git || zypper install -y git
fi

if ! command -v go; then
  curl -sfSLO https://golang.org/dl/$GO_VERSION.linux-amd64.tar.gz
  tar -C /usr/local -xzf $GO_VERSION.linux-amd64.tar.gz

  export_statement="export PATH=/usr/local/go/bin:\$HOME/go/bin:\$PATH"
  if ! grep -Fxq "\$export_statement"  ~/.bashrc; then
    echo "\$export_statement" >> ~/.bashrc
  fi

  PS1=1 && source ~/.bashrc
fi
go version

if ! command -v dlv; then
  go get github.com/go-delve/delve/cmd/dlv
fi
EOF
}

function _remote_run() {
  for c in "${cmds[@]}"; do
    # shellcheck disable=SC2086
    ssh $SSH_OPTS "$REMOTE_USER"@"$REMOTE_HOST" -i "$PRI_KEY" "PS1=1; source ~/.bashrc; $c"
  done
}

function help() {
  filename="$FILENAME.sh"

  cat <<EOF
Usage: $filename <build | remote_setup | remote_debug>

Build the local build
❯ $filename build

Setup the remote host
❯ $filename remote_setup

Debug the remote host
❯ $filename remote_debug

Example:
  PROJECT_DIR=/home/davidko/github/rancher/k3s MAIN_FILE=main.go MAIN_ARGS="server" REMOTE_HOST=10.62.0.18 ./scripts/go-remote-debug.sh debug

EOF
}

_check_args $# 1

case $1 in
build | remote_setup | remote_debug)
  set -o xtrace
  rm -rf "$WORKPLACE" && mkdir -p "$WORKPLACE"

  $1
  ;;

*)
  _error "$1 command not found" help
  exit 1
  ;;
esac
