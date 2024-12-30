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
ssh-copy-id -f -i ~/.ssh/<pub_key> root@<host
```
