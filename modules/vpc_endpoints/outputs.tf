# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_endpoints/outputs.tf ---

output "endpoints" {
  value       = { for k, v in aws_vpc_endpoint.endpoint : k => v.id }
  description = "VPC Endpoints DNS information."
}

output "endpoint_dns" {
  value       = { for k, v in aws_vpc_endpoint.endpoint : k => v.dns_entry[0] }
  description = "DNS information about the VPC endpoints created."
}