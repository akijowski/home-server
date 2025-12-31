---
title: iGPU Passthrough
---

## iGPU Passthrough for an LXC

I run Plex as a media server in my network as an LXC.
In order to take advantage of the Intel iGPU on the host machine,
I pass the GPU device through to the LXC.

It isn't perfect, but I currently rewrite the LXC config file so that
the proper device permissions are set.

I am looking in to using a hookscript instead.
This hookscript can make a temporary device on the host machine to represent the GPU,
which can then be passed to the LXC container with less issues (no rewriting of user/group ids).

### Links

These are links I found useful

- [Article on iGPU passthrough](https://www.saninnsalas.com/pass-intel-igpu-to-an-unprivileged-lxc-container-proxmox/). This is a rough outline of the steps. Although it also has links to more reading.
- [Hookscripts for iGPU](https://github.com/CurtisBlumer/ProxmoxVE-hookscripts). This is the main inspiration for my new approach. I am considering rewriting the script in to a static binary that can be downloaded and run instead of a bash script.
