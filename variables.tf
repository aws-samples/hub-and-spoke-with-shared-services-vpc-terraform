# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/variables.tf ---

# AWS REGION
variable "aws_region" {
  type        = string
  description = "AWS Region to create the environment."
  default     = "eu-west-2"
}

# PROJECT IDENTIFIER
variable "identifier" {
  type        = string
  description = "Project Name, used as identifer when creating resources."
  default     = "hubspoke-shared-services"
}

# INFORMATION ABOUT THE VPCs TO CREATE
variable "vpcs" {
  type        = any
  description = "VPCs to create."
  default = {
    "spoke-vpc-1" = {
      cidr_block       = "10.0.0.0/24"
      workload_subnets = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]
      tgw_subnets      = ["10.0.0.192/28", "10.0.0.208/28", "10.0.0.224/28"]
      number_azs       = 2
      instance_type    = "t2.micro"
      # VPC Flow log type / Default: ALL - Other options: ACCEPT, REJECT
      flow_log_config = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
      }
    }
    "spoke-vpc-2" = {
      cidr_block       = "10.0.1.0/24"
      workload_subnets = ["10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26"]
      tgw_subnets      = ["10.0.1.192/28", "10.0.1.208/28", "10.0.1.224/28"]
      number_azs       = 2
      instance_type    = "t2.micro"
      flow_log_config = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
      }
    }
  }
}

variable "shared_services_vpc" {
  type        = any
  description = "Shared Services VPC."

  default = {
    cidr_block               = "10.129.0.0/24"
    endpoints_subnet_netmask = 28
    tgw_subnet_netmask       = 28
    number_azs               = 2
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