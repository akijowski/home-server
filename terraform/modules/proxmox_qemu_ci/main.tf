locals {
  default_tags = [
    "terraform"
  ]
}

resource "proxmox_vm_qemu" "this" {
  target_node = var.target_node
  vmid        = var.vmid
  name        = var.name
  desc        = var.description

  clone      = var.clone
  full_clone = true
  agent      = 1
  os_type    = "cloud-init"
  vm_state   = "started"

  cores   = var.cores
  sockets = 1
  cpu     = "host"

  memory = var.memory

  boot   = "order=virtio0;net0;ide0"
  scsihw = "virtio-scsi-single"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # ciuser = var.ci_user
  # cipassword = var.ci_password
  # sshkeys = var.ci_ssh_keys
  #   cicustom  = "user=nfs-isos:snippets/user_data_vm-${var.vmid}.yml"
  ipconfig0 = "ip=${var.ip0_ipv4},gw=192.168.50.1,ip6=dhcp"

  disks {
    ide {
      ide0 {
        cloudinit {
          # storage = "nfs-isos"
          storage = "local-lvm"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          iothread = true
          format   = "raw"
          storage  = var.disk1_storage
          # The provider uses the wrong commands to expand the disk size
          # qemu-img resize vs qm resize
          # This leads to timeouts. Better to manually adjust the disk size per the wiki
          # https://pve.proxmox.com/wiki/Resize_disks
          size = "20G"
        }
      }
    }
  }

  tags = join(",", local.default_tags, toset(var.extra_tags))

  serial {
    id   = 0
    type = "socket"
  }

  lifecycle {
    ignore_changes = [
      disks
    ]
  }
}
