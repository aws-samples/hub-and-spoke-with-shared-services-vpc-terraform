# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# VPCs to create - Terraform module used can be found here: https://github.com/aws-ia/terraform-aws-vpc 
module "vpcs" {
  for_each = var.vpcs
  source   = "aws-ia/vpc/aws"
  version  = ">= 1.0.0"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    private = {
      name_prefix  = "private"
      cidrs        = slice(each.value.private_subnets, 0, each.value.number_azs)
      route_to_nat = false
    }
    transit_gateway = {
      name_prefix                                     = "tgw"
      cidrs                                           = slice(each.value.tgw_subnets, 0, each.value.number_azs)
      transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  vpc_flow_logs = {
    log_destination_type = each.value.flow_log_config.log_destination_type
    retention_in_days    = each.value.flow_log_config.retention_in_days
    iam_role_arn         = module.iam_kms.vpc_flowlog_role
    kms_key_id           = module.iam_kms.kms_arn
  }
}


# TRANSIT GATEWAY
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit-Gateway-${var.project_identifier}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "transit-gateway-${var.project_identifier}"
  }
}

# TRANSIT GATEWAY ROUTE TABLES, PROPAGATIONS AND ASSOCIATIONS
module "tgw_route_tables" {
  source = "./modules/tgw_route_tables"

  identifier          = var.project_identifier
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  vpc_tgw_attachments = { for k, v in module.vpcs : k => v.transit_gateway_attachment_id }
  vpc_types           = { for k, v in var.vpcs : k => v.type }
}

# VPC ROUTES TO THE TRANSIT GATEWAY (to remove once the VPC MODULE has this feature ready)
module "vpc_route_to_tgw" {
  source   = "./modules/vpc_route_to_tgw"
  for_each = module.vpcs

  number_azs         = var.vpcs[each.key].number_azs
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  route_tables       = values({ for k, v in each.value.route_table_by_subnet_type.private : k => v.route_table_id })
}

# EC2 INSTANCES - ONLY IN SPOKE VPCs
module "compute" {
  for_each = {
    for k, v in module.vpcs : k => v
    if var.vpcs[k].type == "spoke"
  }
  source = "./modules/compute"

  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  number_azs               = var.vpcs[each.key].number_azs
  instance_type            = var.vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.spoke_vpc.instance
}

# VPC ENDPOINTS (information taken from locals.tf) - CREATED IN SHARED SERVICES VPC
# VPC ENDPOINTS
module "vpc_endpoints" {
  for_each = {
    for k, v in module.vpcs : k => v
    if var.vpcs[k].type == "shared-services"
  }
  source = "./modules/vpc_endpoints"

  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  endpoints_security_group = local.security_groups.centralized_vpc.endpoints
  endpoints_service_names  = local.endpoint_service_names
}

# PRIVATE HOSTED ZONES
module "phz" {
  source                 = "./modules/phz"
  vpc_ids                = { for k, v in module.vpcs : k => v.vpc_attributes.id }
  endpoint_dns           = module.vpc_endpoints["shared-services-vpc"].endpoint_dns
  endpoint_service_names = local.endpoint_service_names
}

# HYBRID DNS RESOURCES - ROUTE 53 RESOLVER ENDPOINTS AND FORWARDING RULES
module "hybrid_dns" {
  for_each                   = { 
    for k, v in module.vpcs : k => v 
    if var.vpcs[k].type == "shared-services" 
  }
  source                     = "./modules/hybrid_dns"

  identifier                 = var.project_identifier
  vpc_id                     = each.value.vpc_attributes.id
  vpc_name                   = each.key
  vpc_r53endpoint_subnets    = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  r53endpoint_security_group = local.security_groups.r53_endoints
  forwarding_rules           = var.forwarding_rules
}

module "iam_kms" {
  source     = "./modules/iam_kms"
  identifier = var.project_identifier
  aws_region = var.aws_region
}