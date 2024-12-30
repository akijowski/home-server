terraform {
  required_version = ">= 1.9"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5.0"
    }
  }

  backend "s3" {
    bucket = "kijowski-tf-remote-state"
    key    = "home-server/vault.tfstate"
    region = "us-east-1"
  }
}
