variable "aws_region" {
  type        = string
  description = "AWS Region for resources"
  validation {
    condition     = contains(["us-east-1"], var.aws_region)
    error_message = "region must be one of 'us-east-1'"
  }
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID for resources"
}

variable "aws_hosted_zone_name" {
  type        = string
  description = "Name of the Route53 hosted zone for lookup"
}

variable "default_tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    "Project" = "home-server"
  }
}
