packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "proxmox_username" {
  type    = string
  default = "${env("PACKER_PROXMOX_USER")}!${env("PACKER_PROXMOX_TOKEN_ID")}"
}

variable "proxmox_token" {
  type    = string
  default = env("PACKER_PROXMOX_TOKEN_SECRET")
}

variable "ansible_ssh_pub_key_file" {
  type      = string
  default   = "/home/admin/.ssh/github_akijowski.pub"
  sensitive = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.ansible_ssh_pub_key_file)) == false
    error_message = "ERROR Private SSH Key."
  }
}

locals {
  clone_vm         = "debian13-trixie-multi-packer"
  project_root_dir = abspath("${path.root}/../..")
  terraform_dir    = abspath("${local.project_root_dir}/terraform/proxmox/packer/manifests")
}

source "proxmox-clone" "debian-multihome" {

  clone_vm = local.clone_vm

  proxmox_url = "https://proxmox.kijowski.casa:8006/api2/json"
  username    = var.proxmox_username
  token       = var.proxmox_token
  node        = "hyperion"

  // SSH (packer)
  ssh_username              = "packer"
  ssh_timeout               = "20m"
  ssh_keypair_name          = "packer_id_ed25519"
  ssh_private_key_file      = "~/.ssh/packer_id_ed25519"
  ssh_clear_authorized_keys = false # this doesn't seem to work, so I remove them in a provisioner

  vm_id         = 9100
  template_name = "hashicorp-debian13"

  cores    = 4
  cpu_type = "host"
  memory   = 4096

  # keep an empty cloud-init drive attached
  cloud_init           = true
  cloud_init_disk_type = "ide"

  os              = "l26"
  bios            = "seabios"
  machine         = "q35"
  scsi_controller = "virtio-scsi-pci"

  vga {
    type   = "qxl"
    memory = 16
  }
  # Note: adding a disks block does not resize or remove the existing scsi0/cloud-image

}

build {
  name    = "hyperion"
  sources = ["source.proxmox-clone.debian-multihome"]

  // generic plays
  provisioner "ansible" {
    user = "packer"
    # ssh_authorized_key_file = var.ansible_ssh_pub_key_file
    galaxy_file            = "${local.project_root_dir}/ansible/linux-requirements.yaml"
    galaxy_force_with_deps = true
    playbook_file          = "${local.project_root_dir}/packer/ansible/linux-playbook.yaml"
    roles_path             = "${local.project_root_dir}/packer/ansible/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${local.project_root_dir}/ansible/ansible_packer.cfg",
      "ANSIBLE_LOG_PATH=${local.project_root_dir}/packer/ansible/.logs/${build.name}-${build.ID}.log"
    ]
    extra_arguments = []

  }
  // install consul
  provisioner "ansible" {
    user = "packer"
    # ssh_authorized_key_file = var.ansible_ssh_pub_key_file
    galaxy_file            = "${local.project_root_dir}/ansible/linux-requirements.yaml"
    galaxy_force_with_deps = true
    playbook_file          = "${local.project_root_dir}/ansible/hashicorp/packer_consul.yaml"
    roles_path             = "${local.project_root_dir}/ansible/hashicorp/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${local.project_root_dir}/ansible/ansible_packer.cfg",
      "ANSIBLE_LOG_PATH=${local.project_root_dir}/packer/ansible/.logs/${build.name}-${build.ID}.log"
    ]
    extra_arguments = []

  }

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      // clean image identifiers
      "sudo cloud-init clean --machine-id --seed",
      "sudo rm /etc/hostname /etc/ssh/ssh_host_* /var/lib/systemd/random-seed"
    ]
  }

  provisioner "shell" {
    inline = [
      // remove ssh configs
      "sudo truncate -s 0 /root/.ssh/authorized_keys",
      "sudo truncate -s 0 /home/debian/.ssh/authorized_keys",
      "sudo sed -i 's/^#PasswordAuthentication\\ yes/PasswordAuthentication\\ no/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#PermitRootLogin\\ prohibit-password/PermitRootLogin\\ no/' /etc/ssh/sshd_config",
      // remove packer user ssh keys, TODO: look in to this
      "sudo rm -f /home/packer/.ssh/authorized_keys"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  post-processor "manifest" {
    output = "${local.terraform_dir}/hashicorp_${build.ID}.json"
    custom_data = {
      build_timestamp = "${timestamp()}"
      build_node      = "hyperion"
      clone_vm        = local.clone_vm
      packer_version  = "${packer.version}"
      consul_version  = "TODO"
    }
  }
}
