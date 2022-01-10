# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "instances_created" {
    value = module.compute
    description = "Instances created in each VPC"
}

output "route53_resolver_endpoints" {
    value = module.hybrid_dns["shared_services-vpc"]
    description = "Route 53 Resolver Endpoints"
}

output "kms_key" {
    value = module.iam_kms.kms_arn
    description = "KMS key ARN"
} 

output "private_hosted_zones" {
    value = module.phz.private_hosted_zones
    description = "Private Hosted Zones"
}

output "transit_gateway" {
    value = module.transit_gateway.tgw_id
    description = "Transit Gateway ID"
} 

output "vpcs" {
    value = {for key, value in module.vpc: key => value.vpc_id}
    description = "List of VPCs created"
}

output "vpc_endpoints" {
  value = {for key, value in module.vpc_endpoints["shared_services-vpc"].endpoints_info: key => value.dns_name}
  description = "DNS name (regional) of the VPC endpoints created."
}