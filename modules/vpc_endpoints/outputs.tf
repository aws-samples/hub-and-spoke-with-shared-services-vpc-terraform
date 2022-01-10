# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_endpoints/outputs.tf ---

output "endpoints_info" {
  value       = { for key, value in aws_vpc_endpoint.endpoint : key => value.dns_entry[0] }
  description = "VPC Endpoints DNS information."
}