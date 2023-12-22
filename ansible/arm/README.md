# Automatic Ripping Machine

"Automatically" rip discs from a disc drive with [MakeMKV](https://www.makemkv.com) and optionally transcode with Handbrake or FFMpeg.

## Project

- [Github](https://github.com/automatic-ripping-machine/automatic-ripping-machine)

## How it is used

ARM is installed as a full Proxmox VM.
This is because the privledges required to run an LXC that can also read USB devices on the host machine is troublesome.
As a VM the USB is passed from the Host to the Guest by following the Proxmox documentation[^1].

### Docker

The easiest way to get this service up and running was to install Docker on the guest[^2], pass in the USB device from the host, and co-opt their "docker run" script[^3].

### Caddy

Caddy is installed as a reverse proxy to the running service.
Caddy performs TLS using AWS Route53 DNS challenges.

## Links

- https://tdarr.k8s.home.kijowski.io

## TODO

- [ ] Switch from Docker to [PodMan](https://podman.io)
- [ ] Install the Container as a Systemd service (podman can help with this)

[^1]: [Proxmox Docs](https://pve.proxmox.com/wiki/USB_Devices_in_Virtual_Machines)
[^2]: [setup script](https://github.com/automatic-ripping-machine/automatic-ripping-machine/blob/main/scripts/docker-setup.sh)
[^3]: [docker run](https://github.com/automatic-ripping-machine/automatic-ripping-machine/blob/main/scripts/docker/start_arm_container.sh)
