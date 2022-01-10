# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_endpoints/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC where the EC2 instance(s) are created."
}

variable "vpc_info" {
  type        = any
  description = "Information about the VPC where the EC2 instance(s) are created."
}

variable "endpoints_security_group" {
  type        = any
  description = "Information about the Security Groups to create - for the VPC endpoints."
}

variable "endpoint_service_names" {
  type        = any
  description = "Information about the VPC endpoints to create."
}