provider "proxmox" {
  pm_api_url = var.pve_api_url
}

locals {
  vms = {
    traefik0 = {
      name        = "traefik0"
      description = "Traefik node. Managed by Terraform"
      target_node = "phoebe"
      vmid        = 0
      cpu         = 1
      memory      = 2048 # 2 GiB
      ip0_ipv4    = "192.168.50.14/24"
      extra_tags  = ["traefik", "ubuntu", "ansible"]
    }
    k3s0 = {
      name        = "k3s0"
      description = "k3s node. Primary. Managed by Terraform"
      target_node = "hyperion"
      vmid        = 0
      cpu         = 2
      memory      = 8192 # 8 GiB
      ip0_ipv4    = "192.168.50.20/24"
      extra_tags  = ["k3s", "ubuntu", "ansible"]
    }
    k3s1 = {
      name        = "k3s1"
      description = "k3s node. Managed by Terraform"
      target_node = "mnemosyne"
      vmid        = 0
      cpu         = 8 # vroom
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
