packer {
  required_plugins {
    proxmox = {
      # version = "~> 1"
      # https://github.com/hashicorp/packer-plugin-proxmox/issues/307
      version = "1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "proxmox-iso" "image" {
  // PVE login
  // Or just use the fqdn and validate the cert
  insecure_skip_tls_verify = true
  proxmox_url              = var.pve_api_url
  username                 = var.pve_username
  token                    = var.pve_token

  // SSH (packer)
  ssh_username              = var.ssh_username
  ssh_timeout               = var.ssh_timeout
  ssh_keypair_name          = var.ssh_keypair_name
  ssh_private_key_file      = var.ssh_private_key_file
  ssh_clear_authorized_keys = true

  os                   = "l26"
  template_description = "Packer generated template image on ${timestamp()}"

  // System
  machine    = "q35"
  bios       = var.vm_bios == "ovmf" ? "ovmf" : "seabios"
  qemu_agent = true

  // Disks
  scsi_controller = "virtio-scsi-single"
  disks {
    type         = "virtio"
    io_thread    = true
    storage_pool = "local-lvm" // All nodes must have this available to store the template
    disk_size    = "20G"
    format       = "raw"
    cache_mode   = "writeback"
  }

  // Cloud-init
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm" // All nodes must have this available to store the template

  // CPU & Memory
  sockets  = "1"
  cores    = "1"
  cpu_type = "host"
  memory   = "2048"

  // Network
  network_adapters {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = "false"
  }
}
