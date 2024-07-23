# K3s Management Cluster

I heard you like kubernetes.

I decided to create a kubernetes cluster to manage the primary kubernetes cluster.

1. This management cluster has fewer resource requirements. It does not need to be HA, or even multi-node.
1. It allows for separation of resources, I could theoretically move this cluster "anywhere" and still maintain control over the primary cluster.
1. It provides a logical separation of tools for _managing_ the lab, and applications that I want to _run_ in the lab.

The mgmt cluster provides 3 things:

1. A UI to manage Ansible playbooks
1. A UI to manage kubernetes manifests
1. A remote development environment

## Ansible

The playbooks to create the cluster through Ansible are found in `ansible/k3s`.
The inventory and variables are under `ansible/inventory/group_vars` and `ansible/inventory/k3s.yml`.
