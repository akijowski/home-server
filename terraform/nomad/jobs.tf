locals {
  any_dcs = ["*"]
  nas_ip  = data.dns_a_record_set.nas.addrs[0]
  system_apps = {
    "rd-csi-nfs-ctrl" = {
      vars = {
        datacenters    = jsonencode(local.any_dcs)
        namespace      = jsonencode(local.namespaces["core"].name)
        nfs_server     = local.nas_ip
        nfs_share      = "/mnt/tank1600/nomad/pvs"
        nfs_mount_opts = "defaults,bg,intr,_netdev,retry=5"
      }
    }
    "rd-csi-nfs-node" = {
      vars = {
        datacenters    = jsonencode(local.any_dcs)
        namespace      = jsonencode(local.namespaces["core"].name)
        nfs_server     = local.nas_ip
        nfs_share      = "/mnt/tank1600/nomad/pvs"
        nfs_mount_opts = "defaults,bg,intr,_netdev,retry=5"
      }
    }
  }
  apps = {
    "traefik" = {
      vars = {
        datacenters           = jsonencode(local.any_dcs)
        namespace             = jsonencode(local.namespaces["core"].name)
        traefik_image_version = "v3.2"
        domain                = "kijowski.casa"
        # pinned to this IP
        # Deprecated for DHCP and private DNS
        # nomad_ipv4        = "192.168.50.32"
        nomad_address     = "https://server.nomad.kijowski.casa:4646" # loadbalanced DNS records
        acme_email        = "agkijow@gmail.com"
        tpl_traefik       = file("${path.module}/appdata/traefik/traefik.yml.tpl")
        tpl_traefik_rules = file("${path.module}/appdata/traefik/rules.yml.tpl")
      }
    }
    "whoami" = {
      vars = {
        datacenters = jsonencode(local.any_dcs)
        namespace   = jsonencode(local.namespaces["core"].name)
        domain      = "kijowski.casa"
      }
    }
    "homebridge" = {
      vars = {
        datacenters              = jsonencode(local.any_dcs)
        namespace                = jsonencode(local.namespaces["core"].name)
        homebridge_image_version = "2024-12-19"
      }
    }
    "fileflows" = {
      vars = {
        datacenters      = jsonencode(local.any_dcs)
        namespace        = jsonencode(local.namespaces["core"].name)
        ff_image_version = "latest"
        ff_volumes = [
          {
            name = "fileflows-cache"
            src  = "fileflows-cache"
            dest = "/temp"
          },
          {
            name = "fileflows-config"
            src  = "fileflows-config"
            dest = "/app/Data"
          },
          {
            name = "fileflows-common"
            src  = "fileflows-common"
            dest = "/app/common"
          },
          {
            name = "arm-media"
            src  = "arm-media"
            dest = "/opt/arm/media"
          },
          {
            name = "plex-movies"
            src  = "plex-movies"
            dest = "/opt/plex/libraries/movies"
          },
          {
            name = "plex-tv-shows"
            src  = "plex-tv-shows"
            dest = "/opt/plex/libraries/tv-shows"
          },
          {
            name = "plex-uhd-movies"
            src  = "plex-uhd-movies"
            dest = "/opt/plex/libraries/uhd-movies"
          }
        ]
      }
    }
    "arrstack" = {
      vars = {
        datacenters = jsonencode(local.any_dcs)
        namespace   = jsonencode(local.namespaces["core"].name)
        # https://hotio.dev/containers/radarr/
        radarr_image_tag = "release-5.19.3.9730"
        sonarr_image_tag = "release-4.0.13.2932"
        bazarr_image_tag = "release-1.5.1"
        arr_volumes = [
          {
            name = "plex-movies"
            src  = "plex-movies"
            dest = "/data/plex/libraries/movies"
          },
          {
            name = "plex-tv-shows"
            src  = "plex-tv-shows"
            dest = "/data/plex/libraries/tv-shows"
          },
          {
            name = "plex-uhd-movies"
            src  = "plex-uhd-movies"
            dest = "/data/plex/libraries/uhd-movies"
          }
        ]
      }
    }
    "registry" = {
      vars = {
        datacenters           = jsonencode(local.any_dcs)
        namespace             = jsonencode(local.namespaces["core"].name)
        registry_ui_image_tag = "2.5-debian"
        registry_image_tag    = "2.8"
      }
    }
  }
  nfs_volumes = {
    "traefik-acme" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "1GiB"
    }
    "radarr-config" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "2GiB"
    }
    "sonarr-config" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "2GiB"
    }
    "bazarr-config" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "2GiB"
    }
    "container-registry" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "20GiB"
    }
    "homebridge-storage" = {
      namespace       = local.namespaces["core"].name
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      capacity_max    = "20GiB"
    }
  }
}

resource "nomad_job" "file_apps" {
  for_each = local.apps

  jobspec = templatefile("${path.module}/templates/${each.key}.hcl.tpl", each.value.vars)

  depends_on = [nomad_namespace.this, nomad_csi_volume.rd-nfs]
}

resource "nomad_job" "file_system_apps" {
  for_each = local.system_apps

  jobspec = templatefile("${path.module}/templates/${each.key}.hcl.tpl", each.value.vars)

  # Monitor and wait for these jobs to finish before moving on
  detach = false

  depends_on = [nomad_namespace.this]
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

  depends_on = [nomad_namespace.this, nomad_job.file_system_apps]
}
