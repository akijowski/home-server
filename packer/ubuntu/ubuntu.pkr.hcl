locals {
  boot_iso = {
    type         = "scsi"
    storage_pool = "nfs-isos"
    download_pve = false
    unmount      = true
    file         = var.iso_file["ubuntu24"]
    checksum     = var.iso_checksum["ubuntu24"]
  }
}
build {
  source "proxmox-iso.image" {
    name          = "ubuntu24-hyperion"
    node          = "hyperion"
    vm_id         = var.vm_id >= 0 ? var.vm_id : 8000
    template_name = "ubuntu24-noble"

    boot_command = var.boot_cmd_ubuntu22
    boot_wait    = "5s"
    http_content = {
      "/meta-data" = file("configs/meta-data")
      "/user-data" = templatefile("configs/user-data",
        {
          ssh_public_key         = chomp(file(var.ssh_public_key_file))
          ansible_ssh_public_key = chomp(file(var.ansible_ssh_public_key_file))
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

  source "proxmox-iso.image" {
    name          = "ubuntu24-phoebe"
    node          = "phoebe"
    vm_id         = var.vm_id >= 0 ? var.vm_id : 8001
    template_name = "ubuntu24-noble"

    boot_command = var.boot_cmd_ubuntu22
    boot_wait    = "5s"
    http_content = {
      "/meta-data" = file("configs/meta-data")
      "/user-data" = templatefile("configs/user-data",
        {
          ssh_public_key         = chomp(file(var.ssh_public_key_file))
          ansible_ssh_public_key = chomp(file(var.ansible_ssh_public_key_file))
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

  source "proxmox-iso.image" {
    name          = "ubuntu24-mnemosyne"
    node          = "mnemosyne"
    vm_id         = var.vm_id >= 0 ? var.vm_id : 8002
    template_name = "ubuntu24-noble"

    boot_command = var.boot_cmd_ubuntu22
    boot_wait    = "5s"
    http_content = {
      "/meta-data" = file("configs/meta-data")
      "/user-data" = templatefile("configs/user-data",
        {
          ssh_public_key         = chomp(file(var.ssh_public_key_file))
          ansible_ssh_public_key = chomp(file(var.ansible_ssh_public_key_file))
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

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      // clean image identifiers
      "cloud-init clean --machine-id --seed",
      "rm /etc/hostname /etc/ssh/ssh_host_* /var/lib/systemd/random-seed",
      // remove ssh configs
      "truncate -s 0 /root/.ssh/authorized_keys",
      "sed -i 's/^#PasswordAuthentication\\ yes/PasswordAuthentication\\ no/' /etc/ssh/sshd_config",
      "sed -i 's/^#PermitRootLogin\\ prohibit-password/PermitRootLogin\\ no/' /etc/ssh/sshd_config"
    ]
  }

  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
}
