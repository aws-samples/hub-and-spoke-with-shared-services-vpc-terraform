# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/hybrid_dns/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to place the Route 53 Resolver Endpoints."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to place the Route 53 Resolver Endpoints."
}

variable "vpc_r53endpoint_subnets" {
  type        = any
  description = "List of subnets to place the Route 53 Resolver Endpoints."
}

variable "r53endpoint_security_group" {
  type        = any
  description = "Information about the Security Groups to create."
}

variable "forwarding_rules" {
  type        = any
  description = "Forwarding rules to on-premises DNS servers."
}