provider "proxmox" {
  endpoint = var.pve_url
  # https://registry.terraform.io/providers/bpg/proxmox/latest/docs#vm-and-container-id-assignment
  # random_vm_ids = true
}

locals {
  hyperion = "hyperion"
  pve01    = "pve01"
  pve02    = "pve02"

  pve_templates = {
    (local.hyperion) = 8000
    (local.pve01)    = 8001
    (local.pve02)    = 8002
  }

  usb_devices = {
    "dvdrom" = {
      node    = local.hyperion
      comment = "usb3.0 blu-ray dvd-rom"
      id      = "174c:55aa"
    }
    "dvdrom-path" = {
      node    = local.hyperion
      comment = "usb3.0 port1 left side, dvd-rom"
      id      = "174c:55aa"
      path    = "2-3"
    }
  }

  tmpl_vars = {
    tmpl_node_hyperion = local.hyperion
    tmpl_node_pve01    = local.pve01
    tmpl_node_pve02    = local.pve02
  }

  pve_vms = merge(
    # Remove K3s cluster for now, will rebuild
    # yamldecode(templatefile("${path.module}/vms/k3s.cluster.yaml", local.tmpl_vars)),
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

  started = try(each.value.started, true)
  on_boot = try(each.value.on_boot, false)

  cores  = try(each.value.cores, null)
  memory = try(each.value.memory, null)

  disks = each.value.disks

  usb_devices = try(each.value.usb_devices, {})

  ipv4_addr             = each.value.ipv4_addr
  ipv4_gw               = try(each.value.ipv4_gw, null)
  network_bridge        = try(each.value.network_bridge, "vmbr0")
  vlan_id               = try(each.value.vlan_id, 0)
  extra_network_devices = try(each.value.extra_network_devices, {})

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
      path = try(each.value.path, null)
    }
  ]
}
