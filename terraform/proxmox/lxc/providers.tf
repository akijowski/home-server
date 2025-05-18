terraform {
  required_version = ">= 1.9"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.77.0"
    }
  }

  backend "s3" {
    bucket = "kijowski-tf-remote-state"
    key    = "home-server/proxmox/lxc.tfstate"
    region = "us-east-1"
  }
}

provider "proxmox" {
  endpoint = var.pve_url
  # https://registry.terraform.io/providers/bpg/proxmox/latest/docs#vm-and-container-id-assignment
  # random_vm_ids = true
}
