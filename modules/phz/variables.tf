# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/phz/variables.tf ---

variable "vpc_ids" {
  type        = map(string)
  description = "VPC IDs to associate the PHZs created."
}

variable "endpoint_dns" {
  type        = any
  description = "DNS information about the VPC endpoints created in the Shared Services VPC."
}

variable "endpoint_service_names" {
  type        = any
  description = "Information about the PHZs to create."
}