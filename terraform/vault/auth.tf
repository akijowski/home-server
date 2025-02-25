locals {
  nomad_server_url = "https://server.nomad.kijowski.casa:4646" # loadbalanced DNS records
  entities = {
    "ansible" = {
      name     = "ansible"
      policies = ["ansible"]
      metadata = {
        description = "Auth entity used by ansible"
      }
    }
  }
  nomad_jwt_roles = {
    "default" = {
      policies = ["default"]
    }
    "traefik" = {
      policies = ["traefik"]
      bound_claims = {
        nomad_namespace = "core"
        nomad_job_id    = "traefik"
      }
      token_period_sec = 7200 # 2 hours
    }
  }
}

resource "vault_identity_entity" "this" {
  for_each = local.entities

  name              = each.value.name
  metadata          = try(each.value.metadata, {})
  external_policies = true # separate resource
}

resource "vault_identity_entity_policies" "this" {
  for_each = vault_identity_entity.this

  policies  = local.entities[each.key].policies
  entity_id = each.value.id
}

# Set up ansible token generation for playbooks
# Manage tokens with the Vault CLI
resource "vault_token_auth_backend_role" "ansible" {
  role_name              = "ansible"
  allowed_policies       = local.entities["ansible"].policies
  allowed_entity_aliases = [local.entities["ansible"].name]

  orphan                 = true
  token_period           = "86400" # 24h
  renewable              = true
  token_explicit_max_ttl = "115200" # 30 days
}

# Vault Agent Approle
resource "vault_auth_backend" "approle" {
  type        = "approle"
  description = "Vault AppRole authentication for simple service accounts"
}

resource "vault_approle_auth_backend_role" "nomad_cluster" {
  backend            = vault_auth_backend.approle.path
  role_name          = "nomad-cluster"
  token_policies     = ["default", "nomad-certs"]
  secret_id_num_uses = 0 # unlimited uses

  token_type    = "batch"
  token_ttl     = 600 # 10 minutes
  token_max_ttl = 900 # 15 minutes
}

# Nomad Workload Identities
# https://developer.hashicorp.com/nomad/docs/integrations/vault/acl#nomad-workload-identities
resource "vault_jwt_auth_backend" "nomad" {
  path        = "nomad_jwt"
  type        = "jwt"
  description = "JWT ACL for Nomad workload identities"

  jwks_url    = "${local.nomad_server_url}/.well-known/jwks.json"
  jwks_ca_pem = sensitive(vault_pki_secret_backend_intermediate_set_signed.intermediate.certificate)

  default_role = "nomad-default"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "168h" # 1 week
    token_type        = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "nomad" {
  for_each = local.nomad_jwt_roles

  backend   = vault_jwt_auth_backend.nomad.path
  role_type = "jwt"
  role_name = try(each.value.name, "nomad-${each.key}")

  claim_mappings = {
    "nomad_namespace" = "nomad_namespace"
    "nomad_job_id"    = "nomad_job_id"
    "nomad_task"      = "nomad_task"
  }

  bound_audiences = ["vault.kijowski.casa"]
  bound_claims    = try(each.value.bound_claims, {})

  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true

  token_policies = sort(each.value.policies)
  token_type     = "service"
  token_period   = try(each.value.token_period_sec, 1800) # default 30 minutes
}
