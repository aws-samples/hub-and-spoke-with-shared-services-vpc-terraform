# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/hybrid_dns/main.tf ---

# ROUUTE 53 RESOLVER ENDPOINTS
# Inbound
resource "aws_route53_resolver_endpoint" "inbound_endpoint" {
  name               = "inbound-endpoint-${var.identifier}"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.r53_endpoints_sg["inbound"].id]

  dynamic "ip_address" {
    for_each = var.vpc_r53endpoint_subnets[*]
    iterator = subnet_id
    content {
      subnet_id = subnet_id.value
    }
  }
}

# Outbound
resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  name               = "inbound-endpoint-${var.identifier}"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.r53_endpoints_sg["outbound"].id]

  dynamic "ip_address" {
    for_each = var.vpc_r53endpoint_subnets[*]
    iterator = subnet_id
    content {
      subnet_id = subnet_id.value
    }
  }
}

# ROUTE 53 FORWARDING RULES
resource "aws_route53_resolver_rule" "forwarding_rule" {
  for_each             = var.forwarding_rules
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

# SECURITY GROUPS
resource "aws_security_group" "r53_endpoints_sg" {
  for_each    = var.r53endpoint_security_group
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

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
    Name = "${var.vpc_name}-${each.value.name}-${var.identifier}"
  }
}