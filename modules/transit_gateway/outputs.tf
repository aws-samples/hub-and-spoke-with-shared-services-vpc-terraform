# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/transit_gateway/outputs.tf ---

output "tgw_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "Transit Gateway ID"
}

output "tgw_attachments" {
  value       = { for key, value in aws_ec2_transit_gateway_vpc_attachment.tgw_attachments : key => value.id }
  description = "List of Transit Gateway VPC Attachments"
}


