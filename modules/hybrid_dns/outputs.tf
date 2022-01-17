# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/hybrid_dns/outputs.tf ---

output "inbound_endpoint" {
  value       = aws_route53_resolver_endpoint.inbound_endpoint.id
  description = "Route 53 Inbound Resolver Endpoint ID"
}

output "outbound_endpoint" {
  value       = aws_route53_resolver_endpoint.outbound_endpoint.id
  description = "Route 53 Outbound Resolver Endpoint ID"
}