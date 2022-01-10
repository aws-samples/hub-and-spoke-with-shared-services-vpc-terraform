# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc/main.tf ---

# List of AZs available in the AWS Region
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_info.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.identifier}"
  }
}

# Default Security Group
# Ensuring that the default SG restricts all traffic (no ingress and egress rule). It is also not used in any resource
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id
}

# SUBNETS
# Private Subnets - either to create instances or VPC endpoints
resource "aws_subnet" "vpc_private_subnets" {
  count             = var.vpc_info.number_azs
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = [for i in range(0, 3) : cidrsubnet(var.vpc_info.cidr_block, 8, i)][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${var.identifier}-${count.index + 1}"
  }
}

# TGW Subnets - for TGW ENIs
resource "aws_subnet" "vpc_tgw_subnets" {
  count             = var.vpc_info.number_azs
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = [for i in range(129, 132) : cidrsubnet(var.vpc_info.cidr_block, 12, i)][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-tgw-subnet-${var.identifier}-${count.index + 1}"
  }
}

# Route53 Endpoint Subnet - Conditional if the VPC is Centralized one
resource "aws_subnet" "vpc_r53endpoint_subnets" {
  count             = length(regexall("shared_services", var.vpc_name)) > 0 ? var.vpc_info.number_azs : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = [for i in range(200, 203) : cidrsubnet(var.vpc_info.cidr_block, 12, i)][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-r53endpoint-subnet-${var.identifier}-${count.index + 1}"
  }
}

# ROUTE TABLES
# Private Subnet Route Table
resource "aws_route_table" "vpc_private_subnet_rt" {
  count  = var.vpc_info.number_azs
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-private-subnet-rt-${var.identifier}-${count.index + 1}"
  }
}

resource "aws_route_table_association" "vpc_private_subnet_rt_assoc" {
  count          = var.vpc_info.number_azs
  subnet_id      = aws_subnet.vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.vpc_private_subnet_rt[count.index].id
}

# TGW Subnet Route Table
resource "aws_route_table" "vpc_tgw_subnet_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-tgw-subnet-rt-${var.identifier}"
  }
}

resource "aws_route_table_association" "vpc_private_rt_assoc" {
  count          = var.vpc_info.number_azs
  subnet_id      = aws_subnet.vpc_tgw_subnets[count.index].id
  route_table_id = aws_route_table.vpc_tgw_subnet_rt.id
}

# Route53 Endpoints Subnet Route Table - Conditional if the VPC is Centralized one
resource "aws_route_table" "vpc_r53endpoint_subnet_rt" {
  count  = length(regexall("shared_services", var.vpc_name)) > 0 ? var.vpc_info.number_azs : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-r53-endpoints-subnet-rt-${var.identifier}-${count.index + 1}"
  }
}

resource "aws_route_table_association" "vpc_r53_endpoint_rt_assoc" {
  count          = length(regexall("shared_services", var.vpc_name)) > 0 ? var.vpc_info.number_azs : 0
  subnet_id      = aws_subnet.vpc_r53endpoint_subnets[count.index].id
  route_table_id = aws_route_table.vpc_r53endpoint_subnet_rt[count.index].id
}

# VPC FLOW LOGS
# VPC Flow Log Resource
resource "aws_flow_log" "vpc_flowlog" {
  iam_role_arn    = var.vpc_flowlog_role
  log_destination = aws_cloudwatch_log_group.flowlogs_lg.arn
  traffic_type    = var.vpc_info.flowlog_type
  vpc_id          = aws_vpc.vpc.id
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "flowlogs_lg" {
  name              = "${var.vpc_name}-lg-vpc-flowlogs-${var.identifier}"
  retention_in_days = 7
  kms_key_id        = var.kms_key
}


