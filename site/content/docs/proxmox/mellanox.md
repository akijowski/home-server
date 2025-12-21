---
title: 'Mellanox'
---
## Mellanox Cards for Proxmox

I use SFP+ network cards with fiber-optic cables between one of my Proxmox host machines and my switch.
This is to achieve 10G networking, which is helpful for the TrueNAS VM.
The NIC I use are Mellanox cards.
Configuring these cards is a bit of a challenge, since it requires drivers and configuration on the host.

### Links

Useful links

- [Flashing Mellanox CX-3 firmware](https://forums.servethehome.com/index.php?threads/flashing-stock-mellanox-firmware-to-oem-emc-connectx-3-ib-ethernet-dual-port-qsfp-adapter.20525/#post-198015)
- [Getting CX-3 to work on Proxmox](https://forums.servethehome.com/index.php?threads/problems-making-sr-iov-work-in-proxmox-for-mellanox-cx3.42618/#post-404650)
- [CX-3 Not Recognized by mst start](https://www.reddit.com/r/homelab/comments/18a0mzk/mellanox_connectx3_is_not_recognized_by_firmware/)
  - use `mst start --with_unknown`
- [Mellanox CX-4 or newer tips and tricks](https://forums.servethehome.com/index.php?threads/mellanox-connectx-4-or-newer-bluefield-tips-tricks.47779/)
- [Proxmox Forums: ConnectX-3 and SRIOV](https://forum.proxmox.com/threads/how-to-configure-mellanox-connectx-3-cards-for-sriov-and-vfs.121927/)
- [Blog: Adding ConnectX-3 to Proxmox](https://redeyeninja.com/2021/11/18/adding-mellanox-connectx3-dual-port-40gbe-and-intel-pro-1000-vt-quad-gigabit-nic-to-proxmox-thru-iommu-sriov/)

### Connect-X3

My first card was a ConnectX-3 which I found on eBay for cheap.
I flashed the firmware and was able to configure it with SRIOV virtual functions (VF).
I then passed these VFs to the NAS VM.

These are the basic steps I followed to configure the NIC on Proxmox.

#### Modify Grub Config

`/etc/default/grub`

```text
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```

#### Update /etc/modules

```text
# /etc/modules: kernel modules to load at boot time.
#
# This file contains the names of kernel modules that should be loaded
# at boot time, one per line. Lines beginning with "#" are ignored.
# Parameters can be specified after the module name.
# PCI Passthrough
#vfio
#vfio_iommu_type1
#vfio_pci
```

#### Update initramfs

After updating grub and modules.

```bash
update-initramfs -u -k all
```

```bash
reboot
```

#### Add firmware and configure

Before PVE9 and Linux Kernel 6.17, this version of Mellanox Firmware Tools (MFT) worked: **4.22.1-526-LTS**.

I saved these tools in `/opt/mellanox`

```bash
wget https://www.mellanox.com/downloads/MFT/mft-4.22.1-526-x86_64-deb.tgz
```

SHA256: `b676f9fdecf570a49614299e071e45dee33159aac380691a23928ad42e0a4c68`

Make sure to install pre-requisites

```bash
apt-get install gcc make dkms pve-headers-$(uname -r)
```

```bash
tar -xvzf mft-4.22.1-526-x86_64-deb.tgz
cd mft-4.22.1-526-x86_64-deb/
./install.sh
```

Start the tool

```bash
mst start
mst status
```

#### Updated kernel configs

Proxmox needs to have the kernel configured.
This can be done by writing config files in `/etc/modprobe.d/`.
I am including default Proxmox ones for reference.

##### blacklist.conf

```text
# Prevent Proxmox from using these PCIe devices (sas and melanox)
blacklist mpt3sas
```

##### mlx4_core.conf

```text
# Mellanox config for eth devices
# Must update device configs before enabling
# https://forum.proxmox.com/threads/how-to-configure-mellanox-connectx-3-cards-for-sriov-and-vfs.121927/
# https://redeyeninja.com/2021/11/18/adding-mellanox-connectx3-dual-port-40gbe-and-intel-pro-1000-vt-quad-gigabit-nic-to-proxmox-thru-iommu-sriov/
# Check /opt/mellanox
# This configures 2 vfs on each port
options mlx4_core num_vfs=2,2,0 port_type_array=2,2 probe_vf=2,2,0
# Performance tuning for eth config
options mlx4_core enable_sys_tune=1
options mlx4_en inline_thold=0
options mlx4_core log_num_mgm_entry_size=-7
```

##### mlx4-vfio.conf

```text
# SFP Mellanox NIC for TrueNAS
# not necessary
##options vfio-pci ids=15b3:1003,15b3:0050
```

This configures the SAS device for my TrueNAS VM

##### sas-vfio.conf

```text
# SAS PCIe Device for TrueNAS
options vfio-pci ids=1000:0072,1028:1f1c
```
