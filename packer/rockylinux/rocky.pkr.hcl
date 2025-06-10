locals {
  boot_iso = {
    type         = "scsi"
    storage_pool = "nfs-isos"
    download_pve = false
    unmount      = true
    file         = var.iso_file["rocky9"]
    checksum     = var.iso_checksum["rocky9"]
  }
}

build {
  source "proxmox-iso.image" {
    name          = "rockylinux9-pve01"
    node          = "pve01"
    vm_id         = var.vm_id >= 0 ? var.vm_id : 8201
    template_name = "rockylinux9"

    boot_command = var.boot_cmd_rocky9
    boot_wait    = "5s"
    http_content = {
      "/ks.cfg" = templatefile("configs/ks.cfg",
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
    // EFI
    efi_config {
      efi_storage_pool = "local-lvm"
      efi_format       = "raw"
      efi_type         = "4m"
    }
  }

  source "proxmox-iso.image" {
    name          = "rockylinux9-pve02"
    node          = "pve02"
    vm_id         = var.vm_id >= 0 ? var.vm_id : 8202
    template_name = "rockylinux9"

    boot_command = var.boot_cmd_rocky9
    boot_wait    = "5s"
    http_content = {
      "/ks.cfg" = templatefile("configs/ks.cfg",
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
      iso_file         = local.boot_iso.file
      iso_checksum     = local.boot_iso.checksum
    }
    // EFI
    efi_config {
      efi_storage_pool = "local-lvm"
      efi_format       = "raw"
      efi_type         = "4m"
    }
  }

  provisioner "ansible" {
    user                   = "${var.ssh_username}"
    galaxy_file            = "${path.cwd}/ansible/linux-requirements.yaml"
    galaxy_force_with_deps = true
    playbook_file          = "${path.cwd}/ansible/linux-playbook.yaml"
    roles_path             = "${path.cwd}/ansible/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg",
      "ANSIBLE_PYTHON_INTERPRETER=/usr/libexec/platform-python"
    ]
    extra_arguments = [
      "--extra-vars", "display_skipped_hosts=false",
      "--extra-vars", "ansible_username=ansible",
      "--extra-vars", "ansible_key=https://github.com/akijowski.keys"
    ]

  }

  provisioner "shell" {
    inline = [
      // clean image identifiers
      "rm /etc/hostname /var/lib/systemd/random-seed",
      // remove ssh configs
      "truncate -s 0 /root/.ssh/authorized_keys",
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
}
