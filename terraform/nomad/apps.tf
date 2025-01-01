locals {
  any_dcs = ["*"]
  apps = {
    "traefik" = {
      vars = {
        datacenters           = jsonencode(local.any_dcs)
        namespace             = jsonencode(local.namespaces["core"].name)
        traefik_image_version = "v3.2"
        domain                = "kijowski.casa"
        nomad_address         = "192.168.50.31"
      }
    }
    "rd-csi-nfs-ctrl" = {
      vars = {
        datacenters    = jsonencode(local.any_dcs)
        namespace      = jsonencode(local.namespaces["core"].name)
        nfs_server     = "192.168.50.4"
        nfs_share      = "/mnt/tank1600/nomad/pvs"
        nfs_mount_opts = "defaults,bg,intr,_netdev,retry=5"
      }
    }
    "rd-csi-nfs-node" = {
      vars = {
        datacenters    = jsonencode(local.any_dcs)
        namespace      = jsonencode(local.namespaces["core"].name)
        nfs_server     = "192.168.50.4"
        nfs_share      = "/mnt/tank1600/nomad/pvs"
        nfs_mount_opts = "defaults,bg,intr,_netdev,retry=5"
      }
    }
  }
  nfs_volumes = {
    "traefik-acme" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "2GiB"
    }
  }
}

resource "nomad_job" "file_apps" {
  for_each = local.apps

  jobspec = templatefile("${path.module}/apps/${each.key}.hcl.tpl", each.value.vars)

  depends_on = [nomad_namespace.this, nomad_csi_volume.rd-nfs]
}

# https://gitlab.com/rocketduck/csi-plugin-nfs/-/blob/main/nomad/example.volume?ref_type=heads
# Troubleshooting: https://github.com/hashicorp/nomad/issues/11839
resource "nomad_csi_volume" "rd-nfs" {
  for_each = local.nfs_volumes

  plugin_id = "rocketduck-nfs"
  volume_id = try(each.value.volume_id, each.key)
  name      = try(each.value.name, each.key)
  namespace = each.value.namespace

  capability {
    access_mode     = each.value.access_mode
    attachment_mode = each.value.attachment_mode
  }

  capacity_min = try(each.value.capacity_min, null)
  capacity_max = try(each.value.capacity_max, null)

  # parameters = {
  #   # controlled by NFS Server
  #   "uid"  = "2400"
  #   "gid"  = "2400"
  #   "mode" = "0770"
  # }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [nomad_namespace.this]
}
