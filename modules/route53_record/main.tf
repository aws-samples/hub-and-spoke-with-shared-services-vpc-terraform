# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/route53_record/main.tf ---

# DNS Records
resource "aws_route53_record" "endpoint_record" {
  for_each = toset(var.record_names)

  zone_id = var.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = var.endpoint_dns_information.dns_name
    zone_id                = var.endpoint_dns_information.hosted_zone_id
    evaluate_target_health = true
  }
}