# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/phz/outputs.tf ---

output "private_hosted_zones" {
  value       = { for key, value in aws_route53_zone.private_hosted_zone : key => value.id }
  description = "Private Hosted Zones"
}