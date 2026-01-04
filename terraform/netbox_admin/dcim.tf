# https://netboxlabs.com/docs/netbox/features/devices-cabling/
locals {
  devices = {
    roles = {
      consul = {
        name        = "consul-cluster"
        color_hex   = "#e03875"
        description = "Consul cluster (server) devices"
        tags        = ["consul"]
      }
    }
  }
}

resource "netbox_device_role" "this" {
  for_each = local.devices.roles

  name        = each.value.name
  color_hex   = replace(each.value.color_hex, "#", "")
  description = each.value.description
  tags        = try(each.value.tags, null)
}
