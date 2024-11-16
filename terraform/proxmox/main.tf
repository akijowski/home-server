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
      cpu         = 2
      memory      = 2048
      ip0_ipv4    = "192.168.50.14/24"
      extra_tags  = ["traefik", "ubuntu", "ansible"]
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
