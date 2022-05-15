# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/main.tf ---

# TRANSIT GATEWAY ROUTE TABLES
# Spoke VPC
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_tgw_rt" {
  transit_gateway_id = var.transit_gateway_id
  tags = {
    Name = "spoke-vpc-rt-${var.identifier}"
  }
}
# Centralized Endpoints VPC
resource "aws_ec2_transit_gateway_route_table" "shared_services_vpc_tgw_rt" {
  transit_gateway_id = var.transit_gateway_id
  tags = {
    Name = "shared-services-vpc-rt-${var.identifier}"
  }
}

# TRANSIT GATEWAY RT ASSOCIATIONS
# Spoke VPC Attachments association to Spoke VPC TGW Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpc_tgw_association" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "spoke"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_tgw_rt.id
}

# Centralized Endpoints VPC Attachment association to Centralized Endpoints TGW Route Table
resource "aws_ec2_transit_gateway_route_table_association" "centralized_vpc_tgw_association" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "shared-services"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services_vpc_tgw_rt.id
}

# TRANSIT GATEWAY PROPAGATIONS
# All the Spoke VPC attachments propagate to the Centralized Endpoints TGW Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "spokes_to_centralized_rt_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "spoke"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services_vpc_tgw_rt.id
}

# Centralized Endpoints VPC attachment propagates to the Spoke VPC TGW Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "centralized_to_spoke_rt_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "shared-services"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_tgw_rt.id
}
