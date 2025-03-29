# Templated Traefik policy
# Managed by terraform

#path "auth/agent/certs/*" {
#  capabilities = ["create", "update"]
#}

#path "${kv_v2_root}/data/somepath" {
#  capabilities = ["read", "create"]
#}

# Generate AWS credentials
path "aws/creds/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_job_id}}" {
  capabilities = ["read", "create"]
}

path "aws/sts/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_job_id}}" {
  capabilities = ["read", "create", "update"]
}

# Read secrets based on nomad namespace/job_id
# KV v2 API
path "kv/data/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "kv/data/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}

path "kv/metadata/{{identity.entity.aliases.${nomad_jwt_accessor}.metadata.nomad_namespace}}/*" {
  capabilities = ["list"]
}

path "kv/metadata/*" {
  capabilities = ["list"]
}
