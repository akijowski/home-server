locals {
  virt_clusters = {
    types = {
      proxmox = {
        name = "Proxmox VE"
      }
    }
    groups = {
      main = {
        name = "titans" # PVE cluster name
      }
      mgr = {
        name = "management" # TODO: better name
      }
    }
    clusters = {
      hyperion = {
        name      = "hyperion"
        type_key  = "proxmox"
        group_key = "main"
        site_id   = 1 # home
      }
      pve01 = {
        name      = "pve01"
        type_key  = "proxmox"
        group_key = "main"
        site_id   = 1 # home
      }
      pve02 = {
        name      = "pve02"
        type_key  = "proxmox"
        group_key = "main"
        site_id   = 1 # home
      }
      pvemgr01 = {
        name      = "pvemgr01"
        type_key  = "proxmox"
        group_key = "mgr"
        site_id   = 1 # home
      }
    }
  }
}

resource "netbox_cluster_group" "this" {
  for_each = local.virt_clusters.groups

  name = each.value.name
}

resource "netbox_cluster_type" "this" {
  for_each = local.virt_clusters.types

  name = each.value.name
}

resource "netbox_cluster" "this" {
  for_each = local.virt_clusters.clusters

  name             = each.value.name
  cluster_type_id  = netbox_cluster_type.this[each.value.type_key].id
  cluster_group_id = netbox_cluster_group.this[each.value.group_key].id
  site_id          = each.value.site_id
}
