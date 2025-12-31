---
title: Development
---

## Development

How to bootstrap a development environment,
or how to work in an existing environment is documented under [documentation/development](./documentation/development.md).

[Taskfile](https://taskfile.dev) is used to declare repeatable tasks.

### Devenv

I use [devenv.sh](https://devenv.sh) to manage the development environment.

### Secrets

Secrets are defined with [secretspec](https://secretspec.dev).
Onepassword (1Password) is used as the secret store.
I use a service account token to access a dedicated 1Password vault.
Secretspec is able to pass the secrets from 1Password to devenv so that I can set secrets through environment variables
or as files.

Devenv and Secretspec are managed as part of my OS and can be found [in my NixOS config repo](https://github.com/akijowski/nixos-configuration).
