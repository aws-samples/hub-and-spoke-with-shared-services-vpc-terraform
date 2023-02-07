# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- SPOKE VPCS ----------
# VPC resource - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "spoke_vpcs" {
  for_each = var.vpcs

  source  = "aws-ia/vpc/aws"
  version = "= 3.1.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.hubspoke.transit_gateway.id
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload = { cidrs = slice(each.value.workload_subnets, 0, each.value.number_azs) }
    transit_gateway = {
      cidrs                                           = slice(each.value.tgw_subnets, 0, each.value.number_azs)
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  vpc_flow_logs = {
    log_destination_type = each.value.flow_log_config.log_destination_type
    retention_in_days    = each.value.flow_log_config.retention_in_days
    iam_role_arn         = aws_iam_role.vpc_flowlogs_role.arn
    kms_key_id           = aws_kms_key.log_key.arn
  }
}

# ---------- EC2 INSTANCES & SECURITY GROUP (in each Spoke VPC) ----------
# Data resource to determine the latest Amazon Linux2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# Security Group - EC2 instance
resource "aws_security_group" "spoke_vpc_sg" {
  for_each = module.spoke_vpcs

  name        = local.security_groups.instance.name
  description = local.security_groups.instance.description
  vpc_id      = each.value.vpc_attributes.id

  dynamic "ingress" {
    for_each = local.security_groups.instance.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.security_groups.instance.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${each.key}-instance-security-group-${var.identifier}"
  }
}

# EC2 Instances (one in each AZ)
module "compute" {
  for_each = module.spoke_vpcs
  source   = "./modules/compute"

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })
  number_azs               = var.vpcs[each.key].number_azs
  instance_type            = var.vpcs[each.key].instance_type
  ami_id                   = data.aws_ami.amazon_linux.id
  ec2_iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  ec2_security_group       = aws_security_group.spoke_vpc_sg[each.key].id
}

# ---------- HUB AND SPOKE (CENTRAL SHARED SERVICES VPC) ----------
# Module - https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest
module "hubspoke" {
  source     = "aws-ia/network-hubandspoke/aws"
  version    = "= 2.0.0"
  identifier = var.identifier

  transit_gateway_attributes = {
    name        = "transit-gateway-${var.identifier}"
    description = "Transit-Gateway-${var.identifier}"
  }

  network_definition = {
    type  = "PREFIX_LIST"
    value = aws_ec2_managed_prefix_list.prefix_list.id
  }

  central_vpcs = {
    shared_services = {
      name       = "shared-services-vpc"
      cidr_block = var.shared_services_vpc.cidr_block
      az_count   = var.shared_services_vpc.number_azs

      subnets = {
        endpoints       = { netmask = var.shared_services_vpc.endpoints_subnet_netmask }
        transit_gateway = { netmask = var.shared_services_vpc.tgw_subnet_netmask }
      }
    }
  }

  spoke_vpcs = {
    number_vpcs = length(var.vpcs)
    vpc_information = { for k, v in module.spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
    } }
  }
}

# ---------- MANAGED PREFIX LIST (Spoke VPC CIDR blocks) ----------
resource "aws_ec2_managed_prefix_list" "prefix_list" {
  name           = "prefix_list-${var.identifier}"
  address_family = "IPv4"
  max_entries    = length(var.vpcs)
}

resource "aws_ec2_managed_prefix_list_entry" "entry" {
  for_each = var.vpcs

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.prefix_list.id
}

# ---------- VPC ENDPOINTS ----------
resource "aws_vpc_endpoint" "endpoint" {
  for_each = local.endpoint_service_names

  vpc_id              = module.hubspoke.central_vpcs["shared_services"].vpc_attributes.id
  service_name        = each.value.name
  vpc_endpoint_type   = each.value.type
  subnet_ids          = values({ for k, v in module.hubspoke.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  security_group_ids  = [aws_security_group.endpoints_vpc_sg["vpc_endpoints"].id]
  private_dns_enabled = each.value.private_dns
}

# Security Groups (VPC endpoints and Route53 Resolver Endpoints)
resource "aws_security_group" "endpoints_vpc_sg" {
  for_each = local.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.hubspoke.central_vpcs["shared_services"].vpc_attributes.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${each.key}-shared-services-security-group-${var.identifier}"
  }
}

# ---------- ROUTE 53 RESOLVER ENDPOINTS ----------
# Route 53 Resolver Endpoints
resource "aws_route53_resolver_endpoint" "inbound_endpoint" {
  name               = "inbound-endpoint-${var.identifier}"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.endpoints_vpc_sg["r53_inbound_endpoint"].id]

  dynamic "ip_address" {
    for_each = values({ for k, v in module.hubspoke.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
    iterator = subnet_id
    content {
      subnet_id = subnet_id.value
    }
  }
}

resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  name               = "outbound-endpoint-${var.identifier}"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.endpoints_vpc_sg["r53_outbound_endpoint"].id]

  dynamic "ip_address" {
    for_each = values({ for k, v in module.hubspoke.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
    iterator = subnet_id
    content {
      subnet_id = subnet_id.value
    }
  }
}

# Forwarding Rule
resource "aws_route53_resolver_rule" "forwarding_rule" {
  for_each = var.forwarding_rules

  domain_name          = each.value.domain_name
  name                 = "${each.key}-${var.identifier}"
  rule_type            = each.value.rule_type
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.id

  dynamic "target_ip" {
    for_each = each.value.target_ip[*]
    iterator = target_ip
    content {
      ip = target_ip.value
    }

  }
}

# ---------- PRIVATE HOSTED ZONES ----------
# Private Hosted Zones resource (associated with the Spoke VPCs)
resource "aws_route53_zone" "private_hosted_zone" {
  for_each = local.endpoint_service_names

  name = each.value.phz_name

  dynamic "vpc" {
    for_each = module.spoke_vpcs
    content {
      vpc_id = vpc.value.vpc_attributes.id
    }
  }
}

# DNS Records pointing to the VPC endpoints (several aliases depending the VPC endpoint)
module "endpoint_record" {
  source   = "./modules/route53_record"
  for_each = local.endpoint_service_names

  zone_id                  = aws_route53_zone.private_hosted_zone[each.key].id
  endpoint_dns_information = aws_vpc_endpoint.endpoint[each.key].dns_entry[0]
  record_names             = each.value.alias
}

# ---------- VPC FLOW LOGS ----------
# IAM Role
data "aws_iam_policy_document" "policy_role_document" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flowlogs_role" {
  name               = "vpc-flowlog-role-${var.identifier}"
  assume_role_policy = data.aws_iam_policy_document.policy_role_document.json
}

# IAM Role Policy
data "aws_iam_policy_document" "policy_rolepolicy_document" {
  statement {
    sid = "2"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroup",
      "logs:DescribeLogStreams"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_role_policy" "vpc_flowlogs_role_policy" {
  name   = "vpc-flowlog-role-policy-${var.identifier}"
  role   = aws_iam_role.vpc_flowlogs_role.id
  policy = data.aws_iam_policy_document.policy_rolepolicy_document.json
}

# KMS key
resource "aws_kms_key" "log_key" {
  description             = "KMS Logs Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.policy_kms_logs_document.json

  tags = {
    Name = "kms-key-${var.identifier}"
  }
}

# Data Source: AWS Caller Identity - Used to get the Account ID
data "aws_caller_identity" "current" {}

# KMS Policy - it allows the use of the Key by the CloudWatch log groups created in this sample
data "aws_iam_policy_document" "policy_kms_logs_document" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Enable KMS to be used by CloudWatch Logs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

# ---------- EC2 IAM ROLE - SSM and S3 access ----------
# IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile_${var.identifier}"
  role = aws_iam_role.role_ec2.id
}

# IAM role
resource "aws_iam_role" "role_ec2" {
  name               = "ec2_ssm_role_${var.identifier}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.policy_document.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

# Policies Attachment to Role
resource "aws_iam_policy_attachment" "ssm_iam_role_policy_attachment" {
  name       = "ssm_iam_role_policy_attachment_${var.identifier}"
  roles      = [aws_iam_role.role_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "s3_readonly_policy_attachment" {
  name       = "s3_readonly_policy_attachment_${var.identifier}"
  roles      = [aws_iam_role.role_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}