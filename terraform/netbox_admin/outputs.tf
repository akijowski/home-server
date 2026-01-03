output "netbox_users" {
  value = { for k, nu in netbox_user.users : k => { username = nu.username, active = nu.active } }
}

output "netbox_regions" {
  value = { for k, nr in netbox_region.regions : k => { id = nr.id, name = nr.name } }
}

output "netbox_site_groups" {
  value = { for k, nsg in netbox_site_group.site_groups : k => { id = nsg.id, name = nsg.name } }
}

output "netbox_sites" {
  value = { for k, ns in netbox_site.sites : k => { id = ns.id, name = ns.name } }
}
