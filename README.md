# Home Server Configuration Management

This project is the configuration for my personal home lab environment.
It is on-going and a test bed for me to continue learning.

It is messy.

Sometimes it is painful.

But I enjoy it.

## Development

How to bootstrap a development environment,
or how to work in an existing environment is documented under [documentation/development](./documentation/development.md).

[Taskfile](https://taskfile.dev) is used to declare repeatable tasks.

## Kubernetes

My lab consists of two kubernetes clusters:

1. A general-purpose cluster running as various VMs and host machines
1. A "management" (mgmt) cluster to externally control and manage the primary cluster.

## Host machines

I am running [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) on a few machines to manange VMs and LXCs. Most of the host machines will be Ubuntu LTS with a few exceptions.

## Tools

A breakdown of information on the applications, or tools, used to manage the network is documented under [documentation/tooling](./documentation/tooling.md).

## Note

Look in to managing brocade switch config with https://github.com/ipcjk/mlxsh
