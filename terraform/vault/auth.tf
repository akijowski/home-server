locals {
  entities = {
    "ansible" = {
      name     = "ansible"
      policies = ["ansible"]
      metadata = {
        description = "Auth entity used by ansible"
      }
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
resource "vault_token_auth_backend_role" "ansible" {
  role_name              = "ansible"
  allowed_policies       = local.entities["ansible"].policies
  allowed_entity_aliases = [local.entities["ansible"].name]

  orphan                 = true
  token_period           = "86400" # 24h
  renewable              = true
  token_explicit_max_ttl = "115200" # 30 days
}

# Using a script to handle tokens
# Leaving this here for posterity
#
# resource "vault_token" "ansible" {
#   role_name    = vault_token_auth_backend_role.ansible.role_name
#   policies     = local.entities["ansible"].policies
#   renewable    = true
#   display_name = "ansible service token"
#   period       = "24h"
#   metadata = {
#     "description" = "For use by ansible playbooks"
#   }
# }

# resource "local_file" "ansible_token" {
#   content = yamlencode({
#     token          = vault_token.ansible.client_token
#     lease_started  = vault_token.ansible.lease_started
#     lease_duration = vault_token.ansible.lease_duration
#   })
#   filename        = "./ansible_token.yaml"
#   file_permission = "0600"
# }
