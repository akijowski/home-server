# Core Playbooks

Playbooks to run common or core tasks based on OS distro.

## Ubuntu

```bash
ansible-playbook -i ./inventory [--limit <host>] core/ubuntu.yaml --tags init [--list-hosts] [--list-tasks] [--extra-vars 'ansible_user=ubuntu']
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
