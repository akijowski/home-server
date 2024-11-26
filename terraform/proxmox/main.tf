provider "proxmox" {
  pm_api_url = var.pve_api_url
}

locals {
  vms = {
    arm0 = {
      name        = "arm0"
      description = <<-EOF
        # Automatic Ripping Machine
        Managed by Terraform.

        https://arm.kijowski.casa
EOF
      target_node = "hyperion"
      vmid        = 0
      cpu         = 2
      memory      = 6144 # 6 GiB
      ip0_ipv4    = "192.168.50.13/24"
      extra_tags  = ["arm", "ubuntu", "ansible"]
    }
    traefik0 = {
      name        = "traefik0"
      description = <<-EOF
        # Traefik node.
        Managed by Terraform.

        https://traefik.kijowski.casa/dashboard/
EOF
      target_node = "phoebe"
      vmid        = 0
      cpu         = 1
      memory      = 2048 # 2 GiB
      ip0_ipv4    = "192.168.50.14/24"
      extra_tags  = ["traefik", "ubuntu", "ansible"]
    }
    homebridge0 = {
      name        = "homebridge0"
      description = <<-EOF
        # Homebridge for Apple HomeKit.
        Managed by Terraform.

        https://homebridge.kijowski.casa
EOF
      target_node = "phoebe"
      vmid        = 0
      cpu         = 1
      memory      = 1024 # 1 GiB
      ip0_ipv4    = "192.168.50.15/24"
      extra_tags  = ["homebridge", "ubuntu", "ansible"]
    }
    k3s0 = {
      name        = "k3s0"
      description = <<-EOF
        # k3s node. Primary.
        Managed by Terraform.
EOF
      target_node = "hyperion"
      vmid        = 0
      cpu         = 2
      memory      = 8192 # 8 GiB
      ip0_ipv4    = "192.168.50.20/24"
      extra_tags  = ["k3s", "ubuntu", "ansible"]
    }
    k3s1 = {
      name        = "k3s1"
      description = <<-EOF
        # k3s node.
        Managed by Terraform.
EOF
      target_node = "mnemosyne"
      vmid        = 0
      cpu         = 8     # vroom
      memory      = 12288 # 12 GiB
      ip0_ipv4    = "192.168.50.21/24"
      extra_tags  = ["k3s", "ubuntu", "ansible"]
    }
  }
}

module "vms" {
  source   = "../modules/proxmox_qemu_ci"
  for_each = local.vms

  name        = each.value.name
  description = each.value.description
  target_node = each.value.target_node
  vmid        = each.value.vmid

  cores  = each.value.cpu
  memory = each.value.memory

  ip0_ipv4 = each.value.ip0_ipv4

  extra_tags = each.value.extra_tags
}
