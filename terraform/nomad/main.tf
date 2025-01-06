provider "nomad" {
  address     = var.nomad_url
  skip_verify = true
}

provider "dns" {}

locals {
  namespaces = {
    "core" = {
      name        = "core"
      description = "Core infrastructure services"
    }
  }
}

data "dns_a_record_set" "nas" {
  host = "truenas.kijowski.casa"
}

resource "nomad_namespace" "this" {
  for_each = local.namespaces

  name        = each.value.name
  description = each.value.description
}
