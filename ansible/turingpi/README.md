# TuringPi Cluster

One-off playbooks to configure fresh images on the TuringPi cluster board.

## Prereq

The target machine should be logged in to prior to running these playbooks.

- Confirm the username and password
- Confirm the current IP address
- Updated `~/.ssh/authorized_keys`

One way to update the set of authorized keys can be to get them from Github:

`curl https://github.com/username.keys >> ~/.ssh/authorized_keys`

## Set Networking (Static IPv4)

This playbook will configure a new ubuntu server image with static networking based on the variables configured in `inventory/group_vars/turingpi_cluster`.

```bash
ansible-playbook -i ./inventory --limit rpi-0 turingpi/networking.yml tags --net [--list-tasks] [-e ansible_user=ubuntu] [-e ansible_host=192.168.50.999]
```

## Ansible Configuration

Use the [Ubuntu Playbook](../core/ubuntu.yaml) with the `--tags users` to configure the host with an `ansible` user and ssh key for access.
