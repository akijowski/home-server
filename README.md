# Home Server Configuration Management

This project contains configuration for the home server project running Ubuntu 20.04.  It borrows heavily from this excellent series by [Digital Ocean](https://www.digitalocean.com/community/conceptual_articles/an-introduction-to-configuration-management-with-ansible).

## Docker

I have added Docker containers to make running Ansible and Kubectl/Helm/Terraform more consistent across machines.  Either image can be built with `./bin/build-*.sh` files.  Run the images with `./bin/run-*.sh`.

## Ansible

Ansible is used to help remotely configure and maintain the state of the home server.  Ansible connects via SSH, **therefore the public key for the user must be in the authorized keys on the remote server**.

### Setup

Inventory is managed in `hosts` and can be included in all ansible commands with `-i hosts`.

**Check inventory**
```bash
ansible-inventory -i hosts --list -y
```

**Check connections**
```bash
ansible all -i hosts -m ping -u <user> [--private-key <ssh-private-key-file>]
```

### Playbooks

This is a quick article on the basics of Ansible playbooks from the [Digital Ocean series](https://www.digitalocean.com/community/cheatsheets/how-to-execute-ansible-playbooks-to-automate-server-setup).

The tutorial [here](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-automate-initial-server-setup-on-ubuntu-18-04) is heavily adapted for the initialization playbook.

To run the a given playbook:

```bash
ansible-playbook <playbook> -i hosts -l <host_name> -u <user> --private-key <key_file> -K
```

The `-K` switch prompts for the BECOME password in Ansible.  This is the password that will be used on the *remote* machine when using `sudo`.  The `-l` switch adds a limit to the included hosts file and should equal one of the names in that file.

## LXC

Rather than install one giant VM as initially planned, instead we will look at running LXC instances on ProxMox.  Most of these LXC instances will be "vanilla" Ubuntu 20.04 LTS and we can use Ansible to configure them with appropriate software to meet their purpose.

### Creating an LXC (CT)

In Proxmox, a new container can be created with the UI.  In the dialog box the base template can be selected along with configuration for CPU, RAM, and Networking.  **Note**: You can upload a public key during creation.  This public key will be added to the `authorized keys` file for the `root` user.  This will make it possible for Ansible to connect over SSH immediately to the instance after creation!

### Default

The default container has only the user `root` and the group `root`.  A separate user should be created and `root` should be secured (no password login, etc).  This setup guide on [Digital Ocean](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04) can be used to create a non-root user.

## Kubernetes

The Proxmox also hosts an Ubuntu VM running [microk8s](https://microk8s.io).  A combination of Kubernetes resources, and Helm files are used to configure the cluster.

To make using Helm and Kubernetes resources more consistent there are Terraform files to manage the resources.  Also I just wanted to experiment with how well that would work (so far TBD).

## TrueNAS

Benchmarking disk performance with fio
https://docs.oracle.com/en-us/iaas/Content/Block/References/samplefiocommandslinux.htm
