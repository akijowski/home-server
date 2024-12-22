terraform {
  required_version = ">= 1.9"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.69.0"
    }
  }

  backend "s3" {
    bucket = "kijowski-tf-remote-state"
    key    = "home-server/proxmox.tfstate"
    region = "us-east-1"
  }
}
