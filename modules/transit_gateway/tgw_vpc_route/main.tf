# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/transit_gateway/tgw_vpc_route/main.tf ---

resource "aws_route" "private_to_tgw_route" {
  count                  = length(var.private_subnet_rts)
  route_table_id         = var.private_subnet_rts[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

resource "aws_route" "r53_endpoint_to_tgw_route" {
  count                  = length(var.route53_endpoint_subnet_rts)
  route_table_id         = var.route53_endpoint_subnet_rts[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}