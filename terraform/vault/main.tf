provider "vault" {
  token = var.vault_token
}

# The log file is created and managed with the Vault ansible role
resource "vault_audit" "file" {
  type        = "file"
  description = "File audit"
  options = {
    file_path = "/opt/vault/logs/vault.log"
  }
}
