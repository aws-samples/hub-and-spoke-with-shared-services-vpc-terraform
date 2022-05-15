# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "instances_created" {
  value       = {for k, v in module.compute: k => v.instances_created}
  description = "Instances created in each VPC"
}

output "route53_resolver_endpoints" {
  value       = module.hybrid_dns["shared-services-vpc"]
  description = "Route 53 Resolver Endpoints"
}

output "kms_key" {
  value       = module.iam_kms.kms_arn
  description = "KMS key ARN"
}

output "private_hosted_zones" {
  value       = module.phz.private_hosted_zones
  description = "Private Hosted Zones"
}

output "transit_gateway" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "Transit Gateway ID"
}

output "vpcs" {
  value       = { for k, v in module.vpcs : k => v.vpc_attributes.id }
  description = "List of VPCs created"
}

output "vpc_endpoints" {
  value       = module.vpc_endpoints["shared-services-vpc"].endpoints
  description = "DNS name (regional) of the VPC endpoints created."
}