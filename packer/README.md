# Packer

Packer templates for building VMs.
Currently I am only planning on building VM templates through Proxmox.

Ubuntu build times are currently 5-10 minutes.
There have been some issues running on all three nodes at once, so rebuilding with an `-only` flag may be needed.

This configuration is based off the work of [ChristianLempa](https://github.com/ChristianLempa/boilerplates/tree/main/packer/proxmox) with modifications to meet my requirements.

Additional configuration is based off of [packer-proxmox-template](https://github.com/trfore/packer-proxmox-templates/tree/main).
I trimmed it down to meet my more limited use case.
