# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc/variables.tf ---

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

variable "vpc_flowlog_role" {
  type        = string
  description = "Role to allow VPC Flow Logs to publish in CloudWatch Logs Group."
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN to encrypt at rest the logs in CloudWatch."
}