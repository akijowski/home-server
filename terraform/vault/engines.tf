resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv-v2"
  description = "KV secrets engine. Version 2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_mount" "pki" {
  path                  = "pki"
  type                  = "pki"
  description           = "PKI certificates secrets engine"
  max_lease_ttl_seconds = 315360000 # 10 years
}

resource "vault_mount" "pki_int" {
  path                  = "pki_int"
  type                  = vault_mount.pki.type
  description           = "PKI intermediate certificates secrets engine"
  max_lease_ttl_seconds = 315360000 # 10 years
}

resource "vault_aws_secret_backend" "aws" {
  description               = "AWS credential generation secrets engine"
  default_lease_ttl_seconds = 43200  # 12 hours
  max_lease_ttl_seconds     = 172800 # 48 hours
}
