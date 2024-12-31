terraform {
  required_version = "~> 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "kijowski-tf-remote-state"
    key    = "home-server/aws-dns.tfstate"
    region = "us-east-1"
  }
}
