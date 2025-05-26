locals {
  hyperion = "hyperion"
  pve01    = "pve01"
  pve02    = "pve02"

  lxc_ubuntu = "nfs-isos:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  # pve_lxcs = {
  #   plex-lxc = [{
  #     target_node = local.pve01
  #     description = "Managed by Terraform"
  #     tmplfile    = local.lxc_ubuntu_tmpl
  #     ipv4_addr   = "192.168.50.10/24"
  #     disk = {
  #       size = 64
  #     }
  #   }]
  # }
  tmpl_vars = {
    tmpl_node_hyperion = local.hyperion
    tmpl_node_pve01    = local.pve01
    tmpl_node_pve02    = local.pve02
    tmpl_lxc_ubuntu = local.lxc_ubuntu
  }
  pve_lxcs = merge(
    yamldecode(templatefile("${path.module}/lxcs.yaml", local.tmpl_vars))
  )

  pve_lxcs_map = merge([
    for name, lxcs in local.pve_lxcs :
    merge([
      { for idx, lxc in lxcs : "${name}${idx}" => lxc }
    ]...) # expand list to each element in group
  ]...)
}

data "http" "github_key" {
    url = "https://github.com/akijowski.keys"

    retry {
        attempts = 3
        max_delay_ms = 30000
        min_delay_ms = 500
    }
}

resource "proxmox_virtual_environment_container" "this" {
  for_each = local.pve_lxcs_map

  node_name   = each.value.target_node
  description = each.value.description


  operating_system {
    template_file_id = each.value.tmplfile
    type             = "ubuntu"
  }

  initialization {
    hostname = try(each.value.name, each.key)
    dynamic "dns" {
      for_each = try(each.value.dns, {})

      content {
        domain = dns.value.domain
        servers = dns.value.servers
      }
    }
    ip_config {
      ipv4 {
        address = each.value.ipv4_addr
        gateway = try(each.value.ipv4_gw, null)
      }
      ipv6 {
        address = "dhcp"
      }
    }
    user_account {
      keys = [ for s in split("\n", data.http.github_key.response_body) : chomp(s) if s != "" ]
      password = var.lxc_root_password
    }
  }

  network_interface {
    name   = "eth0"
    bridge = try(each.value.net_bridge, "vmbr0")
  }

  cpu {
    cores = try(each.value.cpu, 1)
  }

  memory {
    dedicated = try(each.value.memory, 1024)
    swap      = try(each.value.swap, 512)
  }

  disk {
      datastore_id = try(each.value.disk.store_id, "local-lvm")
      size = each.value.disk.size
  }

  started       = false
  start_on_boot = false
  # plex - first time making container make privileged so the gpu can be mapped
  unprivileged = false


  # features {
  #   # Have to be root, but this is for record keeping
  #   mount = ["cifs", "nfs"]
  #   nesting = true
  # }

  tags = sort(try(each.value.tags, []))

  lifecycle {
    ignore_changes = [ started ]
  }
}
