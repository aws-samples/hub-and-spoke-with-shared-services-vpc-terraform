# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/phz/variables.tf ---

variable "vpcs" {
  type        = any
  description = "VPC IDs to associate the PHZs created."
}

variable "endpoint_info" {
  type        = any
  description = "Information about the VPC endpoints created in the Shared Services VPC."
}

variable "endpoint_service_names" {
  type        = any
  description = "Information about the PHZs to create."
}