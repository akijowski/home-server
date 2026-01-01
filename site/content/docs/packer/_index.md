---
bookCollapseSection: true
title: ""
---

## Packer

I use Packer mostly to create "golden images" for certain VM configurations.

## Useful Commands

It is assumed all commands are run from `./packer`.

### Formatting

Format packer files

```bash
packer fmt -recursive .
```

### Validating

Validate the packer template

```bash
packer init ./common
packer validate ./ubuntu
```

### Build

Build all templates

```bash
packer init ./common
packer build ./ubuntu
```

Build specific template

```bash
packer build -only=proxmox-iso.ubuntu24-pve01 .
```

## Images

### Hashicorp

TODO: fill this out with more info
