# Templated Nomad Certs policy
# Managed by terraform

path "${pki_int_root}/issue/nomad-server" {
  capabilities = ["update"]
}

path "${pki_int_root}/issue/nomad-client" {
  capabilities = ["update"]
}
