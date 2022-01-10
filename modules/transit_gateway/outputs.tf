# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/transit_gateway/outputs.tf ---

output "tgw_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "Transit Gateway ID"
}


