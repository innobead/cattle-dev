#!/usr/bin/env bash

PRJ_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")

cd "$PRJ_DIR"
source ./hack/version.sh

rm -rf .build || true
mkdir -p .build

tar --exclude-from=.tarignore -zcv . -f .build/"$NAME-$TAG".tar.gz
