# Templated Traefik policy
# Managed by terraform

# Create PKI certs for services
path "${pki_int_root}/issue/auth" {
  capabilities = ["create", "update"]
}

# TODO Read certs for vault

#path "auth/agent/certs/*" {
#  capabilities = ["create", "update"]
#}

#path "${kv_v2_root}/data/somepath" {
#  capabilities = ["read", "create"]
#}

# Read secrets based on nomad namespace/job_id
path "secret/data/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "secret/data/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}

path "secret/metadata/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_namespace}}/*" {
  capabilities = ["list"]
}

path "secret/metadata/*" {
  capabilities = ["list"]
}
