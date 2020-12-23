#!/usr/bin/env bash

set -o errexit
set -o pipefail

zypper ref
zypper in -y -t pattern devel_basis
zypper in -y glibc-devel-static