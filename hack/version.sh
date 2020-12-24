#!/usr/bin/env bash

NAME=$(basename "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")")
TAG=$(git rev-parse --abbrev-ref HEAD)