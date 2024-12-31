provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = var.default_tags
  }
}

data "aws_route53_zone" "this" {
  name = var.aws_hosted_zone_name
}

locals {
  a_records = yamldecode(file("./records/a_records.yaml"))
}

resource "aws_route53_record" "a_records" {
  for_each = local.a_records

  name    = can(each.value.prefix) ? "${each.value.prefix}.${var.aws_hosted_zone_name}" : "${each.key}.${var.aws_hosted_zone_name}"
  type    = "A"
  ttl     = "7200"
  records = sort(each.value.records)
  zone_id = data.aws_route53_zone.this.zone_id
}
