terraform {
  required_version = ">= 1.9"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }

  backend "s3" {
    bucket = "kijowski-tf-remote-state"
    key    = "home-server/proxmox.tfstate"
    region = "us-east-1"
  }
}
