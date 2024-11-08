build {
  source "proxmox-iso.image" {
    name         = "ubuntu24-noble-podman"
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
      type             = "scsi"
      iso_storage_pool = "nfs-isos"
      iso_download_pve = false
      unmount          = true
      # iso_url          = var.iso_url["ubuntu24"]
      iso_file     = "nfs-isos:iso/ubuntu-24.04.1-live-server-amd64.iso"
      iso_checksum = var.iso_checksum["ubuntu24"]
    }
    template_name = "ubuntu24-noble-podman"
    vm_id         = var.vm_id["ubuntu24-podman"]
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
