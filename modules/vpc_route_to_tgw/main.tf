# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_vpc_routes/main.tf ---

resource "aws_route" "private_to_tgw_route" {
  count = var.number_azs

  route_table_id         = var.route_tables[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}