# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/variables.tf ---

# AWS REGION
variable "aws_region" {
  type        = string
  description = "AWS Region to create the environment."
  default     = "eu-west-1"
}

# PROJECT IDENTIFIER
variable "project_identifier" {
  type        = string
  description = "Project Name, used as identifer when creating resources."
  default     = "hub-spoke-shared_services"
}

# INFORMATION ABOUT THE VPCs TO CREATE
variable "vpcs" {
  type        = map(any)
  description = "VPCs to create."
  default = {
    "spoke-vpc-1" = {
      cidr_block    = "10.0.0.0/16"
      number_azs    = 1
      instance_type = "t2.micro"
      # VPC Flow log type / Default: ALL - Other options: ACCEPT, REJECT
      flowlog_type = "ALL"
    }
    "spoke-vpc-2" = {
      cidr_block    = "10.1.0.0/16"
      number_azs    = 1
      instance_type = "t2.micro"
      flowlog_type  = "ALL"
    }
    "shared_services-vpc" = {
      cidr_block   = "10.50.0.0/16"
      number_azs   = 2
      flowlog_type = "ALL"
    }
  }
}

variable "on_premises_cidr" {
  type        = string
  description = "On-premises CIDR block."
  default     = "192.168.0.0/16"
}

variable "forwarding_rules" {
  type        = map(any)
  description = "Forwarding rules to on-premises DNS servers."
  default = {
    "example-domain" = {
      domain_name = "example.com"
      rule_type   = "FORWARD"
      target_ip   = ["1.1.1.1", "2.2.2.2"]
    }
    "test-domain" = {
      domain_name = "test.es"
      rule_type   = "FORWARD"
      target_ip   = ["1.1.1.1"]
    }
  }
}