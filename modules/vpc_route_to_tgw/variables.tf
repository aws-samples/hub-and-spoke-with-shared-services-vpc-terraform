# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_route_to_tgw/variables.tf ---

variable "number_azs" {
  type        = number
  description = "Number of Availability Zones used."
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID."
}

variable "route_tables" {
  type        = list(string)
  description = "List of private route tables."
}