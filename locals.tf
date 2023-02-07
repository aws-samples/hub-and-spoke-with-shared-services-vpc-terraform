# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/locals.tf ---

locals {
  security_groups = {
    instance = {
      name        = "instance_security_group"
      description = "Instance SG (Allowing ICMP and HTTP/HTTPS access)"
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

    vpc_endpoints = {
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
    r53_inbound_endpoint = {
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
    r53_outbound_endpoint = {
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

  endpoint_service_names = {
    ssm = {
      name        = "com.amazonaws.${var.aws_region}.ssm"
      type        = "Interface"
      private_dns = false
      phz_name    = "ssm.${var.aws_region}.amazonaws.com"
      alias       = [""]
    }
    ssmmessages = {
      name        = "com.amazonaws.${var.aws_region}.ssmmessages"
      type        = "Interface"
      private_dns = false
      phz_name    = "ssmmessages.${var.aws_region}.amazonaws.com"
      alias       = [""]
    }
    ec2messages = {
      name        = "com.amazonaws.${var.aws_region}.ec2messages"
      type        = "Interface"
      private_dns = false
      phz_name    = "ec2messages.${var.aws_region}.amazonaws.com"
      alias       = [""]
    }
    s3 = {
      name        = "com.amazonaws.${var.aws_region}.s3"
      type        = "Interface"
      private_dns = false
      phz_name    = "s3.${var.aws_region}.amazonaws.com"
      alias       = ["", "*"]
    }
  }
}
