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

  usb_devices = {
    "dvdrom" = {
      node    = local.hyperion
      comment = "usb3.0 blu-ray dvd-rom"
      id      = "174c:55aa"
    }
  }

  default_ipv4_gw = "10.10.10.1"

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

  usb_devices = try(each.value.usb_devices, {})

  ipv4_addr = each.value.ipv4_addr
  ipv4_gw = try(each.value.ipv4_gw, local.default_ipv4_gw)
  vlan_id = try(each.value.vlan_id, 0)

  description = try(each.value.description, "")
  extra_tags  = try(each.value.tags, [])
}

resource "proxmox_virtual_environment_hardware_mapping_usb" "this" {
  for_each = local.usb_devices

  name    = each.key
  comment = each.value.comment
  map = [
    {
      id   = each.value.id
      node = each.value.node
    }
  ]
}
