# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/iam_kms/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "aws_region" {
  type        = string
  description = "AWS Region indicated in the variables - where the resources are created."
}
