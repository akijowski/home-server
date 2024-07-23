# Tooling

This is a brief break-down of the tooling decisions I have currently made for my lab.

## Ansible

Ansible is the primary tool used to configure host machines.
It was the original reason for starting the home lab: I wanted to learn Ansible.
Ansible playbooks are found under the `ansible` directory.
I am learning new approaches to managing machines and playbooks, therefore most of the playbooks are in various states.
Over time my plan is to refactor until there is (mostly) a common approach.

## Kubernetes

Being able to run my own kubernetes cluster was another reason for starting a home lab.
I wanted a place to test new programming languages and software techniques.
I am using k3s for the simplicity but completeness of features.
I have tried microk8s but it was too unpredictable and I didn't like running it as a snap package within the VM.
Kubernetes manifests are found under the `kubernetes` directory.

## Terraform

Terraform is used to manage the fleet of Proxmox machines in the lab.
I tried the Ansible module, but Terraform should provide a more declarative approach.
Each VM and LXC within the lab will be created via Terraform.

## Packer

Packer is used to create VM templates within Proxmox.
These templates will let me bootstrap VM creation in Terraform.

## Semaphore UI

## ArgoCD
