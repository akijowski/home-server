# https://developer.hashicorp.com/vault/docs/secrets/pki/quick-start-root-ca
resource "vault_pki_secret_backend_root_cert" "root" {
  backend      = vault_mount.pki.path
  type         = "internal"
  common_name  = "Vault PKI Root CA"
  ttl          = "87600h" # 10 years
  ou           = "home"
  organization = "kijowski"
  country      = "US"

  depends_on = [vault_mount.pki]
}

resource "vault_pki_secret_backend_config_urls" "root" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["https://vault.kijowski.casa:8200/v1/pki/ca"]
  crl_distribution_points = ["https://vault.kijowski.casa:8200/v1/pki/crl"]
}

# Intermediate CSR
# https://developer.hashicorp.com/vault/docs/secrets/pki/quick-start-intermediate-ca
#
# Create a CSR at the intermediate
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "Vault PKI Intermediate CA"

  depends_on = [vault_mount.pki, vault_mount.pki_int]
}

# Sign the CSR with the root CA
resource "vault_pki_secret_backend_root_sign_intermediate" "root" {
  backend     = vault_mount.pki.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name = "Vault PKI Intermediate CA"
  ttl         = "43800h" # 5 years
}

# Mount the signed CSR at the intermediate CA
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root.certificate
}

# Configure signing urls
resource "vault_pki_secret_backend_config_urls" "intermediate" {
  backend                 = vault_mount.pki_int.path
  issuing_certificates    = ["https://vault.kijowski.casa:8200/v1/pki_int/ca"]
  crl_distribution_points = ["https://vault.kijowski.casa:8200/v1/pki_int/crl"]
}
