# Core Playbooks

Playbooks to run common or core tasks based on OS distro.

## Ubuntu

```bash
ansible-playbook -i ./inventory [--limit <host>] core/ubuntu.yaml --tags init [--list-hosts] [--list-tasks] [--extra-vars 'ansible_user=ubuntu']
```

### Partition Drive

Simple play to format a block device with GPT and ext4 and then mount it to a path.

- `dev_path` the block device to partition
- `dev_name` using gpt a name is required
- `mnt_path` where to mount the filesystem

```bash
ansible-playbook -i ./inventory [--limit <host>] core/ubuntu.yaml --tags partition [--extra-vars 'dev_path=/dev/vdb' --extra-vars 'dev_name=virtio1' --extra-vars 'mnt_path=/mnt/path']
```

## Proxmox

```bash
ansible-playbook -i ./inventory [--limit <host>] core/proxmox.yaml --tags users [--extra-vars 'ansible_user=root']
```

Creates an `admin` and `ansible` user. The `ansible` user should only be used with an ssh key. The `admin` user can be used to login. Use the `passwd` command on each node to set the password.

Copy the ssh key for `root` to the target machines in order to run playbooks.
Use the `-f` flag because the private keys are stored in 1Password and only the public key is needed.
Note that this may cause duplicate keys to be added, so use with caution.

```bash
ssh-copy-id -f -i ~/.ssh/<pub_key> root@<host>
```

## Mellanox

For CX-3 use firmware 4.22.1-417-LTS successfully up until linux kernel 6.17.2-1-pve (2025-10-21T11:55Z) for Proxmox
(6.14.11-4-pve (2025-10-10T08:04Z) was last successful kernel for MFT).
Had to use latest MFT version (4.34.0-145) to get compatibility with kernel 6.17.

Useful links

- [Flashing Mellanox CX-3 firmware](https://forums.servethehome.com/index.php?threads/flashing-stock-mellanox-firmware-to-oem-emc-connectx-3-ib-ethernet-dual-port-qsfp-adapter.20525/#post-198015)
- [Getting CX-3 to work on Proxmox](https://forums.servethehome.com/index.php?threads/problems-making-sr-iov-work-in-proxmox-for-mellanox-cx3.42618/#post-404650)
- [CX-3 Not Recognized by mst start](https://www.reddit.com/r/homelab/comments/18a0mzk/mellanox_connectx3_is_not_recognized_by_firmware/)
  - use `mst start --with_unknown`
- [Mellanox CX-4 or newer tips and tricks](https://forums.servethehome.com/index.php?threads/mellanox-connectx-4-or-newer-bluefield-tips-tricks.47779/)

### Kernel changes mlx4 vs mlx5

There are differences in the kernel modules for mellanox cards.
The module `mlx4_core` can be configured with settings in `/etc/modprobe.d/`.
However `mlx5_core` needs to be set through `/sys/` params.

generic kernel links:

- https://www.baeldung.com/linux/list-loadable-kernel-modules

Flashing XC-4 and newer:

- https://docs.nvidia.com/networking/display/mftv4250/mlxfwmanager+–+firmware+update+and+query+tool <-- Used this tool
- https://network.nvidia.com/support/firmware/nic/
- https://network.nvidia.com/support/firmware/firmware-downloads/

link dump:

- https://enterprise-support.nvidia.com/s/article/HowTo-Configure-SR-IOV-for-ConnectX-4-ConnectX-5-ConnectX-6-with-KVM-Ethernet
- https://forums.servethehome.com/index.php?threads/how-to-use-the-mlx5_core-driver-with-mellanox-connectx-4-lx-in-debian.35663/
- https://pavlokhmel.com/proxmox-virtual-network-interfaces-with-mellanox-infiniband-cards.html <-- this is useful
- https://forum.proxmox.com/threads/tutorial-proxmox-8-mellanox-infiniband-and-sr-iov.146196/ <-- similar to above
