locals {
  local_domains = ["localhost"]
  nomad_domains = ["nomad", "nomad.kijowski.casa"]
}

resource "vault_pki_secret_backend_role" "nomad_server" {
  backend        = vault_mount.pki_int.path
  name           = "nomad-server"
  ttl            = "86400"   # 24 hours
  max_ttl        = "2592000" # 30 days
  generate_lease = true

  allowed_domains    = sort(concat(local.local_domains, local.nomad_domains))
  allow_any_name     = false
  allow_glob_domains = true
  allow_subdomains   = true
  enforce_hostnames  = true

  # Client and Server certs
  client_flag = true
  server_flag = true
}

resource "vault_pki_secret_backend_role" "nomad_client" {
  backend        = vault_mount.pki_int.path
  name           = "nomad-client"
  ttl            = "86400"   # 24 hours
  max_ttl        = "2592000" # 30 days
  generate_lease = true

  allowed_domains    = sort(concat(local.local_domains, local.nomad_domains))
  allow_any_name     = false
  allow_bare_domains = true # Required for email addresses
  allow_glob_domains = false
  allow_subdomains   = true
  allow_ip_sans      = true
  enforce_hostnames  = true

  # Client only certs
  client_flag = true
  server_flag = false
}
