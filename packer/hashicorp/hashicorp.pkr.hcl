locals {
  boot_iso = {
    type         = "scsi"
    storage_pool = "nfs-isos"
    download_pve = false
    unmount      = true
    file         = var.iso_file["ubuntu24"]
    checksum     = var.iso_checksum["ubuntu24"]
  }

  terraform_dir = abspath("${path.root}/../../terraform/proxmox/packer/manifests")
}

variable "consul_version" {
  type        = string
  description = "Consul version"
}

build {
  source "proxmox-iso.image" {
    name          = "hashicorp-hyperion"
    node          = "hyperion"
    vm_id         = var.vm_id >= 0 ? var.vm_id : 8300
    template_name = "hashicorp-stack-${formatdate("YYYYMMDD", timestamp())}"

    boot_command = var.boot_cmd_ubuntu22
    boot_wait    = "5s"
    http_content = {
      "/meta-data" = file("configs/meta-data")
      "/user-data" = templatefile("configs/user-data",
        {
          ssh_public_key = chomp(file(var.ssh_public_key_file))
      })
    }
    // ISO
    boot_iso {
      type             = local.boot_iso.type
      iso_storage_pool = local.boot_iso.storage_pool
      iso_download_pve = local.boot_iso.download_pve
      unmount          = local.boot_iso.unmount
      # iso_url          = var.iso_url["ubuntu24"]
      iso_file     = local.boot_iso.file
      iso_checksum = local.boot_iso.checksum
    }
  }

  provisioner "ansible" {
    user                   = "${var.ssh_username}"
    galaxy_file            = "${path.cwd}/ansible/linux-requirements.yaml"
    galaxy_force_with_deps = true
    playbook_file          = "${path.cwd}/ansible/hashicorp-playbook.yaml"
    roles_path             = "${path.cwd}/ansible/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg",
      "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3"
    ]
    extra_arguments = [
      "--extra-vars", "display_skipped_hosts=false",
      "--extra-vars", "ansible_username=ansible",
      "--extra-vars", "ansible_key=https://github.com/akijowski.keys",
      "--extra-vars", "consul_version=${var.consul_version}"
    ]

  }

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      // clean image identifiers
      "cloud-init clean --machine-id --seed",
      "rm /etc/hostname /etc/ssh/ssh_host_* /var/lib/systemd/random-seed",
      // remove ssh configs
      "truncate -s 0 /root/.ssh/authorized_keys",
      "truncate -s 0 /home/ubuntu/.ssh/authorized_keys",
      "sed -i 's/^#PasswordAuthentication\\ yes/PasswordAuthentication\\ no/' /etc/ssh/sshd_config",
      "sed -i 's/^#PermitRootLogin\\ prohibit-password/PermitRootLogin\\ no/' /etc/ssh/sshd_config"
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
    output = "${local.terraform_dir}/hashicorp-hyperion.json"
    custom_data = {
      build_timestamp = "${timestamp()}"
      consul_version = var.consul_version
    }
  }
}
