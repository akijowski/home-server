# Templated Ansible policy
# Managed by terraform

# Create PKI certs for services
path "${pki_int_root}/issue/auth" {
  capabilities = ["create", "update"]
}

path "${pki_int_root}/issue/server" {
  capabilities = ["create", "update"]
}

path "${pki_int_root}/issue/client" {
  capabilities = ["create", "update"]
}

#path "auth/agent/certs/*" {
#  capabilities = ["create", "update"]
#}

#path "${kv_v2_root}/data/somepath" {
#  capabilities = ["read", "create"]
#}
