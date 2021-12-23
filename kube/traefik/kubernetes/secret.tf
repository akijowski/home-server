provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "aws_access_key_id" {
  description = "The value of the AWS_ACCESS_KEY_ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "The value of the AWS_SECRET_ACCESS_KEY"
  type        = string
  sensitive   = true
}

resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws-creds"
    namespace = "ingress"
    labels = {
      "traefik" = "acme"
    }
  }

  data = {
    "access-key" = var.aws_access_key_id
    "secret-key" = var.aws_secret_access_key
  }
}
