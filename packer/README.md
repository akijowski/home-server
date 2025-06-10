# Packer

Packer templates for building VMs.
Currently I am only planning on building VM templates through Proxmox.

Ubuntu build times are currently 5-10 minutes.
There have been some issues running on all three nodes at once, so rebuilding with an `-only` flag may be needed.

This configuration is based off the work of [ChristianLempa](https://github.com/ChristianLempa/boilerplates/tree/main/packer/proxmox) with modifications to meet my requirements.

Additional configuration is based off of [packer-proxmox-template](https://github.com/trfore/packer-proxmox-templates/tree/main).
I trimmed it down to meet my more limited use case.

## Working Directory

It is assumed all commands are run from `./packer`.

## Formatting

Format packer files

```bash
packer fmt -recursive .
```

## Validating

Validate the packer template

```bash
packer init ./common
packer validate ./ubuntu
```

## Build

Build all templates

```bash
packer init ./common
packer build ./ubuntu
```

Build specific template

```bash
packer build -only=proxmox-iso.ubuntu24-pve01 .
```

## Links

[Packer Docs](https://developer.hashicorp.com/packer/docs/intro)
[Proxmox ISO Plugin](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox)
[Cloud-Init Reference](https://cloudinit.readthedocs.io/en/latest/reference/index.html)
[Ubuntu Autoinstall Reference](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)
[Proxmox Packer Examples](https://github.com/ajschroeder/proxmox-packer-examples/tree/main)
