# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/transit_gateway/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "default_route_table_association" {
  type        = string
  description = "Transit Gateway Default Route Table Association."
  default     = "disable"
}

variable "default_route_table_propagation" {
  type        = string
  description = "Transit Gateway Default Route Table Propagation."
  default     = "disable"
}

variable "vpcs" {
  type        = any
  description = "Information about the VPCs created - to attach them to the Transit Gateway."
}