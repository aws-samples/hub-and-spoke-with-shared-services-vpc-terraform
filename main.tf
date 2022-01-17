# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

module "vpc" {
  for_each         = var.vpcs
  source           = "./modules/vpc"
  identifier       = var.project_identifier
  vpc_name         = each.key
  vpc_info         = each.value
  vpc_flowlog_role = module.iam_kms.vpc_flowlog_role
  kms_key          = module.iam_kms.kms_arn
}

module "transit_gateway" {
  source     = "./modules/transit_gateway"
  identifier = var.project_identifier
  vpcs       = module.vpc
}

module "tgw_vpc_routes" {
  for_each                    = module.vpc
  source                      = "./modules/tgw_vpc_routes"
  tgw_id                      = module.transit_gateway.tgw_id
  private_subnet_rts          = each.value.private_subnet_rts
  route53_endpoint_subnet_rts = each.value.r53_endpoints_subnet_rts

  depends_on = [
    module.transit_gateway.tgw_attachments
  ]
}

module "compute" {
  for_each                 = { for k, v in module.vpc : k => v if v.vpc_type == "spoke" }
  source                   = "./modules/compute"
  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_info                 = each.value
  instance_type            = var.vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.spoke_vpc.instance
}

module "vpc_endpoints" {
  for_each                 = { for k, v in module.vpc : k => v if v.vpc_type == "shared-services" }
  source                   = "./modules/vpc_endpoints"
  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_info                 = each.value
  endpoints_security_group = local.security_groups.centralized_vpc.endpoints
  endpoint_service_names   = local.endpoint_service_names
}

module "phz" {
  source                 = "./modules/phz"
  vpcs                   = { for key, value in module.vpc : key => value.vpc_id }
  endpoint_info          = module.vpc_endpoints["shared_services-vpc"].endpoints_info
  endpoint_service_names = local.endpoint_service_names
}

module "hybrid_dns" {
  for_each                   = { for k, v in module.vpc : k => v if v.vpc_type == "shared-services" }
  source                     = "./modules/hybrid_dns"
  identifier                 = var.project_identifier
  vpc_id                     = each.value.vpc_id
  vpc_name                   = each.key
  vpc_r53endpoint_subnets    = each.value.r53endpoints_subnets
  r53endpoint_security_group = local.security_groups.r53_endoints
  forwarding_rules           = var.forwarding_rules
}

module "iam_kms" {
  source     = "./modules/iam_kms"
  identifier = var.project_identifier
  aws_region = var.aws_region
}