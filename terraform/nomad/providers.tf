terraform {
  required_version = ">= 1.9"
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.4.0"
    }
  }

  backend "s3" {
    bucket = "kijowski-tf-remote-state"
    key    = "home-server/nomad.tfstate"
    region = "us-east-1"
  }
}
