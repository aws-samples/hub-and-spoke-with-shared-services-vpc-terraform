# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/route53_record/variables.tf ---

variable "zone_id" {
  description = "Private Hosted Zone ID."
  type        = string
}

variable "endpoint_dns_information" {
  description = "VPC endpoint DNS information."
  type        = map(string)
}

variable "record_names" {
  description = "List of names to create Route 53 records in the PHZ."
  type        = list(string)
}

