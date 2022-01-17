# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/transit_gateway/main.tf ---

# TRANSIT GATEWAY
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit-Gateway-${var.identifier}"
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = {
    Name = "transit-gateway-${var.identifier}"
  }
}

# TRANSIT GATEWAY ATTACHMENTS
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachments" {
  for_each                                        = var.vpcs
  subnet_ids                                      = each.value.tgw_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = each.value.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${each.key}-tgw-attachment-${var.identifier}"
  }
}

# TRANSIT GATEWAY ROUTE TABLES
# Spoke VPC
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "spoke-vpc-rt-${var.identifier}"
  }
}
# Centralized Endpoints VPC
resource "aws_ec2_transit_gateway_route_table" "shared_services_vpc_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "shared-services-vpc-rt-${var.identifier}"
  }
}

# TRANSIT GATEWAY RT ASSOCIATIONS
# Spoke VPC Attachments association to Spoke VPC TGW Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_vpc_tgw_association" {
  for_each                       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachments : k => v.id if length(regexall("spoke", k)) > 0 }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_tgw_rt.id
}
# Centralized Endpoints VPC Attachment association to Centralized Endpoints TGW Route Table
resource "aws_ec2_transit_gateway_route_table_association" "centralized_vpc_tgw_association" {
  for_each                       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachments : k => v.id if length(regexall("shared_services", k)) > 0 }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services_vpc_tgw_rt.id
}

# TRANSIT GATEWAY PROPAGATIONS
# All the Spoke VPC attachments propagate to the Centralized Endpoints TGW Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "spokes_to_centralized_rt_propagation" {
  for_each                       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachments : k => v.id if length(regexall("spoke", k)) > 0 }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services_vpc_tgw_rt.id
}
# Centralized Endpoints VPC attachment propagates to the Spoke VPC TGW Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "centralized_to_spoke_rt_propagation" {
  for_each                       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.tgw_attachments : k => v.id if length(regexall("shared_services", k)) > 0 }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_tgw_rt.id
}
