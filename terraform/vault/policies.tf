locals {
  policy_tmpl_vars = {
    kv_v2_root   = vault_mount.kvv2.path
    pki_root     = vault_mount.pki.path
    pki_int_root = vault_mount.pki_int.path
    # nomad_jwt_accessor = vault_jwt_auth_backend.nomad.accessor
    nomad_jwt_accessor = "replace-me"
  }
  policies_from_file = [
    "admin",
    "ansible",
    "traefik",
    "nomad-certs"
  ]
}

resource "vault_policy" "files" {
  for_each = { for f in local.policies_from_file : f => f }

  name   = each.key
  policy = templatefile("policies/${each.key}.hcl.tpl", local.policy_tmpl_vars)
}
