provider "proxmox" {
  endpoint = var.pve_url
  # https://registry.terraform.io/providers/bpg/proxmox/latest/docs#vm-and-container-id-assignment
  # random_vm_ids = true
}

locals {
  # vms = {
  # TODO
  # These are now orphaned and will be moved in to Nomad
  # As they are migrated I will remove them from here
  #     arm0 = {
  #       name        = "arm0"
  #       description = <<-EOF
  #         # Automatic Ripping Machine
  #         Managed by Terraform.

  #         https://arm.kijowski.casa
  # EOF
  #       target_node = "hyperion"
  #       vmid        = 0
  #       cpu         = 2
  #       memory      = 6144 # 6 GiB
  #       ip0_ipv4    = "192.168.50.13/24"
  #       extra_tags  = ["arm", "ubuntu", "ansible"]
  #     }
  #     traefik0 = {
  #       name        = "traefik0"
  #       description = <<-EOF
  #         # Traefik node.
  #         Managed by Terraform.

  #         https://traefik.kijowski.casa/dashboard/
  # EOF
  #       target_node = "phoebe"
  #       vmid        = 0
  #       cpu         = 1
  #       memory      = 2048 # 2 GiB
  #       ip0_ipv4    = "192.168.50.14/24"
  #       extra_tags  = ["traefik", "ubuntu", "ansible"]
  #     }
  #     homebridge0 = {
  #       name        = "homebridge0"
  #       description = <<-EOF
  #         # Homebridge for Apple HomeKit.
  #         Managed by Terraform.

  #         https://homebridge.kijowski.casa
  # EOF
  #       target_node = "phoebe"
  #       vmid        = 0
  #       cpu         = 1
  #       memory      = 1024 # 1 GiB
  #       ip0_ipv4    = "192.168.50.15/24"
  #       extra_tags  = ["homebridge", "ubuntu", "ansible"]
  #     }
  #     tdarr0 = {
  #       name        = "tdarr0"
  #       description = <<-EOF
  #         # Tdarr
  #         Managed by Terraform.

  #         https://docs.tdarr.io/docs/welcome/what
  # EOF
  #       target_node = "hyperion"
  #       vmid        = 0
  #       cpu         = 3
  #       memory      = 3072 # 3 GiB
  #       ip0_ipv4    = "192.168.50.36/24"
  #       extra_tags  = ["tdarr", "ubuntu", "ansible"]
  #     }
  #     tdarr1 = {
  #       name        = "tdarr1"
  #       description = <<-EOF
  #         # Tdarr
  #         Managed by Terraform.

  #         https://docs.tdarr.io/docs/welcome/what
  # EOF
  #       target_node = "mnemosyne"
  #       vmid        = 0
  #       cpu         = 3
  #       memory      = 3072 # 3 GiB
  #       ip0_ipv4    = "192.168.50.37/24"
  #       extra_tags  = ["tdarr", "ubuntu", "ansible"]
  #     }
  # }
}

locals {
  hyperion  = "hyperion"
  phoebe    = "phoebe"
  mnemosyne = "mnemosyne"

  pve_templates = {
    (local.hyperion)  = 8000
    (local.phoebe)    = 8001
    (local.mnemosyne) = 8002
  }

  tmpl_vars = {
    tmpl_node_hyperion  = local.hyperion
    tmpl_node_phoebe    = local.phoebe
    tmpl_node_mnemosyne = local.mnemosyne
  }

  pve_vms = merge(
    yamldecode(templatefile("${path.module}/vms/k3s.cluster.yaml", local.tmpl_vars)),
    yamldecode(templatefile("${path.module}/vms/other.yaml", local.tmpl_vars)),
    yamldecode(templatefile("${path.module}/vms/nomad.cluster.yaml", local.tmpl_vars))
  )

  # map each group of vms to {group}{idx} for hostname (unless override). E.g. plex0 => {...vm info...}
  pve_vms_map = merge([
    for name, vms in local.pve_vms :
    merge([
      { for idx, vm in vms : "${name}${idx}" => vm }
    ]...) # expand list to each element in group
  ]...)
}

module "pve_vms" {
  source   = "../modules/proxmox_qemu"
  for_each = local.pve_vms_map

  hostname       = try(each.value.hostname, each.key)
  target_node    = each.value.target_node
  vm_template_id = local.pve_templates[each.value.target_node]

  cores  = try(each.value.cores, null)
  memory = try(each.value.memory, null)

  disks = each.value.disks

  ipv4_addr = each.value.ipv4_addr

  description = try(each.value.description, "")
  extra_tags  = try(each.value.tags, [])
}
