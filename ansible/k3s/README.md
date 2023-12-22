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

## How it is used

K3s is used as the Kubernetes cluster for my entire homelab.
The cluster will run most workloads that do not require certain hardware requirements or privledges.
It will also make for a nice testbed for experiments.
