# K3s Cluster

Lightweight but conformant Kubernetes! :star:

## Project

- [Site](https://k3s.io)
- [Docs](https://docs.k3s.io)
- [Github](https://github.com/k3s-io/k3s/)

### Ansible Role

- [Role repo](https://github.com/PyratLabs/ansible-role-k3s)

This Ansible role seemed better than the "official" Ansible role.
At the time, the official role did not look easy to import in to my playbooks.
Also, the role seemed to have only occasional support compared to this actively maintained role.

> Note: You must run the clusters separately to prevent the Ansible Role from trying to combine the two clusters.
> The way to do this is with the `--limit` flag to choose either `k3s_cluster` or `k3s_mgmt_cluster`.

## How it is used

K3s is used as the Kubernetes cluster for my entire homelab.
The cluster will run most workloads that do not require certain hardware requirements or privileges.
It will also make for a nice testbed for experiments.

## Useful operations

- [Manage K3s](https://github.com/PyratLabs/ansible-role-k3s/tree/main/documentation/operations)

### Starting K3s Cluster

```bash
$ ansible-playbook -i ./inventory k3s/k3s_cluster.yml --become --tags install -e 'k3s_state=started'
```

### Stopping K3s Cluster

```bash
$ ansible-playbook -i ./inventory k3s/k3s_cluster.yml --become --tags install -e 'k3s_state=stopped'
```

### Run for management cluster

```bash
$ ansible-playbook -i ./inventory --limit k3s_mgmt_cluster k3s/k3s_cluster.yml --tags install
```
