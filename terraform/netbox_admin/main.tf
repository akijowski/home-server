data "onepassword_vault" "nixos" {
  name = "nixos"
}

locals {
  tags = {
    manual = {
      name        = "manual"
      color_hex   = "#dd0000"
      description = "managed manually"
    }
    terraform = {
      name        = "terraform"
      color_hex   = "#800080"
      description = "managed by terraform"
      slug        = "tf"
    }
    ansible = {
      name        = "ansible"
      color_hex   = "#65c8c6"
      description = "managed by ansible"
    }
  }
}

resource "netbox_tag" "tags" {
  for_each = local.tags

  name        = each.value.name
  color_hex   = replace(each.value.color_hex, "#", "")
  description = each.value.description
  slug        = try(each.value.slug, null)
}
