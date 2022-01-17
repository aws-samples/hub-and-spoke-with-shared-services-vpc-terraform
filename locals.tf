# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/locals.tf ---

locals {
  security_groups = {
    spoke_vpc = {
      instance = {
        name        = "instance_sg"
        description = "Security Group used in the instances"
        ingress = {
          icmp = {
            description = "Allowing ICMP traffic"
            from        = -1
            to          = -1
            protocol    = "icmp"
            cidr_blocks = ["0.0.0.0/0"]
          }
          http = {
            description = "Allowing HTTP traffic"
            from        = 80
            to          = 80
            protocol    = "tcp"
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
    centralized_vpc = {
      endpoints = {
        name        = "endpoints_sg"
        description = "Security Group for SSM connection"
        ingress = {
          https = {
            description = "Allowing HTTPS"
            from        = 443
            to          = 443
            protocol    = "tcp"
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
    r53_endoints = {
      inbound = {
        name        = "r53endpoint_inbound_sg"
        description = "Security Group for R53 Resolver Inbound Endpoints"
        ingress = {
          tcp_access = {
            description = "Allowing DNS traffic (TCP)"
            from        = 53
            to          = 53
            protocol    = "tcp"
            cidr_blocks = ["${var.on_premises_cidr}"]
          }
          udp_access = {
            description = "Allowing DNS traffic (UDP)"
            from        = 53
            to          = 53
            protocol    = "udp"
            cidr_blocks = ["${var.on_premises_cidr}"]
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
      outbound = {
        name        = "r53endpoint_outbound_sg"
        description = "Security Group for R53 Resolver Outbound Endpoits"
        ingress = {
          tcp_access = {
            description = "Allowing DNS traffic (TCP)"
            from        = 53
            to          = 53
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
          udp_access = {
            description = "Allowing DNS traffic (UDP)"
            from        = 53
            to          = 53
            protocol    = "udp"
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
  }

  endpoint_service_names = {
    ssm = {
      name           = "com.amazonaws.${var.aws_region}.ssm"
      type           = "Interface"
      private_dns    = false
      phz_needed     = true
      phz_name       = "ssm.${var.aws_region}.amazonaws.com"
      phz_multialias = false
    }
    ssmmessages = {
      name           = "com.amazonaws.${var.aws_region}.ssmmessages"
      type           = "Interface"
      private_dns    = false
      phz_name       = "ssmmessages.${var.aws_region}.amazonaws.com"
      phz_multialias = false
    }
    ec2messages = {
      name           = "com.amazonaws.${var.aws_region}.ec2messages"
      type           = "Interface"
      private_dns    = false
      phz_name       = "ec2messages.${var.aws_region}.amazonaws.com"
      phz_multialias = false
    }
    s3 = {
      name           = "com.amazonaws.${var.aws_region}.s3"
      type           = "Interface"
      private_dns    = false
      phz_name       = "s3.${var.aws_region}.amazonaws.com"
      phz_multialias = true
    }
  }
}
