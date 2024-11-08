build {
  source "proxmox-iso.image" {
    name         = "debian12-bookworm"
    boot_command = var.boot_cmd_debian
    boot_wait    = "5s"
    http_content = {
      "/preseed.cfg" = templatefile("configs/preseed.cfg",
        {
          ssh_password_encrypted = bcrypt(var.ssh_password) # this or ssh_password
          ssh_password           = ""
          ssh_public_key         = chomp(file(var.ssh_public_key_file))
      })
    }

    //ISO
    boot_iso {
      type             = "scsi"
      iso_storage_pool = "nfs-isos"
      iso_download_pve = false
      unmount          = true
      # iso_url = var.iso_url["debian12"]
      iso_file     = "nfs-isos:iso/debian-12.7.0-amd64-netinst.iso"
      iso_checksum = var.iso_checksum["debian12"]
    }
    template_name = "debian12-bookworm"
    vm_id         = var.vm_id["debian12"]
  }

  provisioner "shell" {
    inline = [
      // clean image identifiers
      "cloud-init clean --seed",
      "truncate -s 0 /etc/machine-id && ln -sf /etc/machine-id /var/lib/dbus/machine-id",
      "rm /etc/hostname /etc/ssh/ssh_host_* /var/lib/systemd/random-seed",
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
