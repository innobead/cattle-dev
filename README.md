# cattle-dev

This project provides scripts for local development and remote debugging for Rancher projects.

## Prerequisites

Run the below command to install the required dependencies.

```console
./bin/cattle-dev-setup
```

# Usages

## cattle-dev-vm

`cattle-dev-vm` is for creating VMs based on different providers. For now, firecracker, multipass supported. 
It's easy to add new provider by adding the provider script in `./bin/libs/providers` w/ the necessary exported functions including:

- setup
- clean
- ssh_login
- node
- env

```console
❯ ./bin/cattle-dev-vm
Usage: cattle-dev-vm <provider> <setup | clean | ssh_login | node | env>

provider: firecracker | multipass

❯ setup <number of nodes>       Setup nodes
❯ clean                         Clean up nodes
❯ ssh_login <x-th node>         SSH the node
❯ node                          Show node names
❯ env <x-th node>               Show the node environment variables
```

## cattle-dev-remote-debug

`cattle-dev-remote-debug` is for remote debugging the program in the specific project. It supports the below functions.

1. Build the program in the specific project
2. Copy the built executable artifact to the remote VM which can be setup by `cattle-dev-vm` or your own
3. Run the remote debugging against the VM, then you can use the preferred IDE to do the remote debugging 

```console
Usage: cattle-dev-remote-debug <build | debug | remote_setup | remote_debug>

❯ build             Build the local build
❯ debug             build + remote_setup + remote_debug
❯ remote_setup      Setup the remote host
❯ remote_debug      Debug the remote host

Globals Environment Variables: (able to change)
  GO_VERSION=go1.15.6
  REMOTE_USER=root
  REMOTE_HOST=localhost
  REMOTE_DEBUG_PORT=2345
  PRI_KEY=/home/davidko/.ssh/id_rsa
  WORKPLACE=/tmp/cattle-dev-remote-debug
  PROJECT_DIR=/home/davidko/github/innobead/dev
  MAIN_FILE=main.go
  MAIN_ARGS=
  EXEC_FILE=main
  BUILD_CMD=go list -m all || true; go build -gcflags "all=-N -l" -o main main.go

Example:
  PROJECT_DIR=/home/davidko/github/k3s-io/k3s MAIN_FILE=cmd/k3s/main.go MAIN_ARGS="server" REMOTE_HOST=10.62.0.18 cattle-dev-remote-debug build
  PROJECT_DIR=/home/davidko/github/k3s-io/k3s MAIN_FILE=cmd/k3s/main.go MAIN_ARGS="server" REMOTE_HOST=10.62.0.18 cattle-dev-remote-debug remote_setup
  PROJECT_DIR=/home/davidko/github/k3s-io/k3s MAIN_FILE=cmd/k3s/main.go MAIN_ARGS="server" REMOTE_HOST=10.62.0.18 cattle-dev-remote-debug remote_debug
```

## cattle-dev-remote-debug-project

`cattle-dev-remote-debug-project` combines `cattle-dev-vm` and `cattle-dev-remote-debug` to provide remote debugging the specific Rancher projects like k3s, rke2, etc. 
They are defined in `bin/projects` and implemented w/ the necessary exported functions including:

- build
- reset-remote-env

```console
Usage: cattle-dev-remote-debug-project <k3s | rke2>

Globals Environment Variables: (able to change)
  PROJECT_DIR=
  DAPPER_OPTS=DAPPER_MODE=bind GODEBUG=y
  MAIN_ARGS=
  EXEC_FILE=
  FORCE_SETUP_VM=false

Example:
  PROJECT_DIR=/home/davidko/github/k3s-io/k3s MAIN_ARGS="server" EXEC_FILE="dist/artifacts/k3s" cattle-dev-remote-debug-project k3s
```