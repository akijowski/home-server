locals {
  users = {
    ansible = {
      name     = "ansible"
      group_id = 1 # svc_account (created manually for terraform)
      active   = true
    }
  }
}

resource "onepassword_item" "users" {
  for_each = local.users

  vault    = data.onepassword_vault.nixos.uuid
  category = "login"

  title = "netbox - ${each.key}"

  username = each.value.name
  password_recipe {
    length  = 16
    digits  = true
    symbols = true
  }

  section {
    label = "website"
    field {
      label = "href"
      type  = "URL"
      value = "https://netbox.kijowski.casa"
    }
  }

  tags = [
    "terraform",
    "github.com/akijowski/home-server"
  ]
}

resource "netbox_user" "users" {
  for_each = local.users

  username = each.value.name
  password = onepassword_item.users[each.key].password

  active = each.value.active
  staff  = false

  group_ids = toset([
    each.value.group_id
  ])

  depends_on = [onepassword_item.users]
}
