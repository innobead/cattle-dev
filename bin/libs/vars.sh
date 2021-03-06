#!/usr/bin/env bash

DEBUG=${DEBUG:-}
FORCE_INSTALL=${FORCE_INSTALL:-false}

NODE_PREFIX=${NODE_PREFIX:-unknown}
NODE_NUM=${NODE_NUM:-1}
NODE_CPUS=${NODE_CPUS:-1}
NODE_MEM=${NODE_MEM:-2G}
NODE_DISK=${NODE_DISK:-5G}

PUB_KEY=${PUB_KEY:-$HOME/.ssh/id_rsa.pub}
PRI_KEY=${PRI_KEY:-$HOME/.ssh/id_rsa}
SSH_OPTS=${SSH_OPTS:-"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"}