locals {
  default_tags    = ["terraform"]
  default_disk_id = keys(var.disks)[0]
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.hostname
  vm_id       = var.vm_id != 0 ? var.vm_id : null # provider can configure random_vm_ids to handle auto-increment
  description = "${var.description}\n\n_Managed by Terraform_"
  tags        = sort(toset(concat(var.extra_tags, local.default_tags)))

  node_name = var.target_node
  on_boot   = var.on_boot
  started   = var.started
  reboot    = false # if true, seems to always reboot :(

  agent {
    type = "virtio"
    # qemu_guest_agent must be installed
    enabled = true
  }

  tablet_device = true

  clone {
    vm_id = var.vm_template_id
    full  = true
  }

  bios = "seabios"

  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.memory
  }

  boot_order = [var.disks[local.default_disk_id].interface, "net0", "ide0"]

  scsi_hardware = "virtio-scsi-single"

  dynamic "disk" {
    for_each = var.disks

    content {
      datastore_id = disk.value["datastore_id"]
      interface    = disk.value["interface"]
      size         = disk.value["size"]

      aio         = "io_uring"
      iothread    = true
      file_format = "raw"
      cache       = "none"
      backup      = true
    }
  }

  dynamic "usb" {
    for_each = var.usb_devices

    content {
      host    = try(usb.value["host"], null)
      mapping = try(usb.value["mapping"], null)
      usb3    = try(usb.value["usb3"], false)
    }
  }

  # Cloud-Init
  initialization {
    datastore_id = "local-lvm"
    interface    = "ide0"

    ip_config {
      ipv4 {
        address = var.ipv4_addr
        gateway = var.ipv4_gw
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  machine = "q35"

  lifecycle {
    ignore_changes = [
      # Helps avoid issues when importing and dealing with cloud-init
      initialization[0].user_account,
      clone
    ]
  }
}
