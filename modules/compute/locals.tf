# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/compute/locals.tf ---

locals {
  instance_security_group = {
    name        = "instance_sg-${var.vpc_name}"
    description = "Security Group for EC2 instances."
    ingress = {
      icmp = {
        description = "Allowing ICMP traffic"
        from        = -1
        to          = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    egress = {
      any = {
        description = "Any traffic"
        from        = 0
        to          = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }
}