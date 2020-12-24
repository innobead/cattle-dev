#!/usr/bin/env bash

PRJ_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")

cd "$PRJ_DIR"
source ./hack/version.sh

docker build -t "$NAME":"$TAG" .