# Homebridge

HomeKit support for some incompatible devices.

## Project

- [Site](https://homebridge.io)
- [Github Repo](https://github.com/homebridge/homebridge)

## How it is used

Homebridge is installed as a Proxmox LXC.
Running in a container environment looked challenging become Homebridge needed to control certain network functions to work properly.
The role installs via the official repository for Debian/Ubuntu systems.

### Caddy

Caddy is installed as a reverse proxy to the running service.
Caddy performs TLS using AWS Route53 DNS challenges.

## TODO

- [ ] Automatic updates?
