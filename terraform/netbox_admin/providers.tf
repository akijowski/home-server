terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.0"
    }
  }
}

provider "netbox" {
  api_token            = var.netbox_api_token
  allow_insecure_https = true
  default_tags = toset([
    "terraform"
  ])
}

provider "onepassword" {}
