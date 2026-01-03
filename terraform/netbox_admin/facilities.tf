# https://netboxlabs.com/docs/netbox/features/facilities/

locals {
  facilities = {
    regions = {
      us = {
        name        = "us"
        description = "default US region"
      }
    }
    site_groups = {
      home = {
        name        = "home"
        description = "default home group"

      }
    }
    sites = {
      home = {
        name        = "home"
        description = "home on-premise"

        group_name  = "home" # see key
        region_name = "us"   # see key
      }
    }
  }
}

resource "netbox_region" "regions" {
  for_each = local.facilities.regions

  name        = each.value.name
  description = each.value.description
}

resource "netbox_site_group" "site_groups" {
  for_each = local.facilities.site_groups

  name        = each.value.name
  description = each.value.description
}

resource "netbox_site" "sites" {
  for_each = local.facilities.sites

  name        = each.value.name
  description = each.value.description

  timezone = "America/Denver"

  group_id  = netbox_site_group.site_groups[each.value.group_name].id
  region_id = netbox_region.regions[each.value.region_name].id

  # provider tags aren't being applied
  tags = ["terraform"]
}
