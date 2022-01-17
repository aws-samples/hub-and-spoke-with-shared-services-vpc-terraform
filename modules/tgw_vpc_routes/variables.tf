# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_vpc_routes/variables.tf ---

variable "tgw_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "private_subnet_rts" {
  type        = any
  description = "List of private subnets to add the default route to the TGW."
}

variable "route53_endpoint_subnet_rts" {
  type        = any
  description = "List of Route53 Endpoint subnets to add the default route to the TGW."
}