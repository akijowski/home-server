# Home Server Configuration Management

This project contains configuration for the home server project running Ubuntu 20.04.  It borrows heavily from this excellent series by [Digital Ocean](https://www.digitalocean.com/community/conceptual_articles/an-introduction-to-configuration-management-with-ansible).

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

To run the "main" playbook:

```bash
ansible-playbook playbook.yml -i hosts -u <user> -K
```

The `-K` switch prompts for the BECOME password in Ansible.  This is the password that will be used on the *remote* machine when using `sudo`.

## Proxmox

The `proxmox` directory contains a basic ansible playbook to configure the promox host itself.  It can be run with the default `root` user with the following command:

```bash
ansible-playbook proxmox/playbook.yml -l proxmox -i hosts  -u root -k -K
```


## LXC

Rather than install one giant VM as initially planned, instead we will look at running LXC instances on ProxMox.  Most of these LXC instances will be "vanilla" Ubuntu 20.04 LTS and we can use Ansible to configure them with appropriate software to meet their purpose.

### Creating an LXC (CT)

In Proxmox, a new container can be created with the UI.  In the dialog box the base template can be selected along with configuration for CPU, RAM, and Networking.  **Note**: You can upload a public key during creation.  This public key will be added to the `authorized keys` file for the `root` user.  This will make it possible for Ansible to connect over SSH immediately to the instance after creation!

### Default

The default container has only the user `root` and the group `root`.  A separate user should be created and `root` should be secured (no password login, etc).  This setup guide on [Digital Ocean](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04) can be used to create a non-root user.

