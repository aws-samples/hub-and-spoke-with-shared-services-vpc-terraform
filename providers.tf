# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/providers.tf ---

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
  }

  required_version = "~> 1.1.2"
}

# AWS Provider configuration - AWS Region indicated in root/variables.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Hub and Spoke - Shared Services VPC"
      Terraform = "Managed"
      Region    = var.aws_region
    }
  }
}
