# Packer

Packer templates for building VMs.
Currently I am only planning on building VM templates through Proxmox.

This configuration is based off the work of [ChristianLempa](https://github.com/ChristianLempa/boilerplates/tree/main/packer/proxmox) with modifications to meet my requirements.

## Formatting

Format packer files

```bash
packer fmt -recursive ./packer
```

## Links

[Packer Docs](https://developer.hashicorp.com/packer/docs/intro)
[Proxmox ISO Plugin](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox)
[Cloud-Init Reference](https://cloudinit.readthedocs.io/en/latest/reference/index.html)
[Ubuntu Autoinstall Reference](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)
