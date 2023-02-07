# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "vpcs" {
  description = "VPCs created."
  value = {
    spoke           = { for k, v in module.spoke_vpcs : k => v.vpc_attributes.id }
    shared_services = module.hubspoke.central_vpcs["shared_services"].vpc_attributes.id
  }
}

output "transit_gateway" {
  description = "Transit Gateway resources."
  value = {
    id = module.hubspoke.transit_gateway.id
    route_tables = {
      spoke           = module.hubspoke.transit_gateway_route_tables.spoke_vpcs.spokes.id
      shared_services = module.hubspoke.transit_gateway_route_tables.central_vpcs.shared_services.id
    }
  }
}

output "ec2_instances" {
  description = "Instances created in each Spoke VPC."
  value       = { for k, v in module.compute : k => v.instances_created }
}

output "vpc_endpoints" {
  description = "VPC endpoints created."
  value       = { for k, v in aws_vpc_endpoint.endpoint : k => v.id }
}

output "route53_resolver_endpoints" {
  description = "Route 53 Resolver Endpoints."
  value = {
    inbound  = aws_route53_resolver_endpoint.inbound_endpoint.id
    outbound = aws_route53_resolver_endpoint.outbound_endpoint.id
  }
}

output "private_hosted_zones" {
  description = "Private Hosted Zones."
  value       = { for k, v in aws_route53_zone.private_hosted_zone : k => v.id }
}
