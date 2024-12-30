# Templated Admin policy
# Managed by terraform

## System Backend

# Read system health check
path "sys/health" {
  capabilities = ["read", "sudo"]
}

path "sys/audit" {
  capabilities = ["read", "create", "sudo"]
}

# Manage leases
path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

## ACL Policies

# Create, manage ACL policies
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing policies
path "sys/policies/acl" {
  capabilities = ["list"]
}

# Deny changing own policy
path "sys/policies/acl/admin" {
  capabilities = ["read"]
}

## Auth Methods

# Manage auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, delete auth methods
path "sys/auth/*" {
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth" {
  capabilities = ["read"]
}

## IdentityEntity
path "identity/entity/*" {
  capabilities = ["create", "update", "delete", "read"]
}

path "identity/entity/name" {
  capabilities = ["list"]
}

path "identity/entity/id" {
  capabilities = ["list"]
}

path "identity/entity-alias/*" {
  capabilities = ["create", "update", "delete", "read"]
}

path "identity/entity-alias/id" {
  capabilities = ["list"]
}

## KV Secrets Engine

# manage kv secrets engine
path "${kv_v2_root}/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engine
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List secrets engine
path "sys/mounts" {
  capabilities = ["read"]
}

## PKI - Intermediate CA

path "${pki_root}/config/urls" {
  capabilities = ["read"]
}

# Create, update roles
path "${pki_int_root}/roles/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List roles
path "${pki_int_root}/roles" {
  capabilities = ["list"]
}

# Issue certs
path "${pki_int_root}/issue/*" {
  capabilities = ["create", "update"]
}

# Read certs
path "${pki_int_root}/cert/*" {
  capabilities = ["read"]
}

# Revoke certs
path "${pki_int_root}/revoke" {
  capabilities = ["create", "update", "read"]
}

# List certs
path "${pki_int_root}/certs" {
  capabilities = ["list"]
}

# Tidy certs
path "${pki_int_root}/tidy" {
  capabilities = ["create", "update", "read"]
}

path "${pki_int_root}/tidy-status" {
  capabilities = ["read"]
}
