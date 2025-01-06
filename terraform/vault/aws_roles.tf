locals {
  aws_users = {}
  aws_roles = {
    "traefik-role" = {
      role_arns = [
        "arn:aws:iam::976648257138:role/VaultManageDNS"
      ]
    }
  }
}

resource "vault_aws_secret_backend_role" "iam_users" {
  for_each = local.aws_users

  backend         = vault_aws_secret_backend.aws.path
  name            = try(each.value.name, each.key)
  credential_type = "iam_user"

  # user_path  = "/vault/"
  iam_groups = sort(each.value.groups)
  iam_tags = {
    "service"   = try(each.value.name, each.key)
    "managedBy" = "vault"
    "github"    = "https://github.com/akijowski/home-server"
  }
}

resource "vault_aws_secret_backend_role" "iam_roles" {
  for_each = local.aws_roles

  backend         = vault_aws_secret_backend.aws.path
  name            = try(each.value.name, each.key)
  credential_type = "assumed_role"

  role_arns   = sort(each.value.role_arns)
  external_id = "onprem-vault"
  # Maximum and minimum allowed by AWS for assuming roles
  # https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html#API_AssumeRole_RequestParameters
  # Note: Vault does not seem to respect this
  default_sts_ttl = 3600  # 1 hour
  max_sts_ttl     = 43200 # 12 hours
  session_tags = {
    "service"   = try(each.value.name, each.key)
    "managedBy" = "vault"
    "github"    = "https://github.com/akijowski/home-server"
  }
}
