# TuringPi Cluster

One-off playbooks to configure fresh images on the TuringPi cluster board.

## Set Networking (Static IPv4)

This playbook will configure a new ubuntu server image with static networking based on the variables configured in `inventory/group_vars/turingpi_cluster`.

```bash
ansible-playbook -i ./inventory --limit rpi0 turingpi/networking.yml tags --net [--list-tasks] [-e ansible_user=ubuntu] [-e ansible_host=192.168.50.999]
```
