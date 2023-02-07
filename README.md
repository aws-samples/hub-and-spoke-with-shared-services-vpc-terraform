<!-- BEGIN_TF_DOCS -->
# AWS Hub and Spoke Architecture with Shared Services VPC - Terraform Sample

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with Shared Services VPC, with the following centralized services:

- Managing EC2 instances using AWS Sytems Manager - ssm, ssmmessages and ec2messages VPC Endpoints.
- Amazon S3 access (the IAM role created for the EC2 instances allows READ ONLY access). If you want to change it, check the code in the *compute* module
- Hybrid DNS, both inbound and outbound Route 53 Resolver Endpoints are created.

The resources deployed and the architectural pattern they follow is purely for demonstration/testing purposes.

## Prerequisites

- An AWS account with an IAM user with the appropriate permissions
- Terraform installed

## Code Principles:

- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage

- Clone the repository
- Edit the *variables.tf* file in the project root directory. This file contains the variables that are used to configure the VPCs to create, and Hybrid DNS configuration needed to work with your environment.
- To change the configuration about the Security Groups and VPC endpoints to create, edit the *locals.tf* file in the project root directory
- Initialize Terraform using `terraform init`
- Deploy the template using `terraform apply`

**Note** The default number of Availability Zones to use in the Spoke VPCs is 1. For the Shared Services VPC, the default (and minimum) number of AZs to use is 2 - due to configuration requirements for Route 53 Resolver Endpoints. To follow best practices, each resource - EC2 instance, VPC endpoints, and Route 53 Resolver Endpoints - will be created in each Availability Zone. **Keep this in mind** to avoid extra costs unless you are happy to deploy more resources and accept additional costs.

## Deployment

### Centralizing VPC Endpoints

- To centralize the SSM access for the instances created in the Spoke VPCs, 3 VPC endpoints are created with "Private DNS" option disabled: ssm, ssmmessages, and ec2messages. 3 Private Hosted Zones are created and associated with all the VPCs created (Spoke VPCs and Shared Services VPC) to allow DNS resolution.
- The fourth VPC endpoint created is to access Amazon S3. As indicated before, the EC2 instance roles only have *read* permission.
- Amazon S3 interface endpoints **do not support** the private DNS feature. However, thanks to the use of Private Hosted Zones, you can access S3 without having to use the VPC endpoint DNS name all the time. Two resource records are created within the S3 PHZ: one for the apex of the domain, and the second as a wildcard to allow all records within this domain to be resolved to the VPC endpoint. One example you can use to test the access to S3 is the following one: `aws s3 --region {aws_region} ls s3://`

### Hybrid DNS

Both Amazon Route 53 Inbound and Outbound Resolver Endpoints are created. The configuration applied in the *variables.tf* file is not valid (example values). To use the example with your real-environment, please change the following variables:

- **on\_premises\_cidr**: Indicate the CIDR block of your on-premises location to allow DNS traffic in the Inbound Endpoints. This value is added in the Security Group attached to that endpoint.
- **forwarding\_rules**: Add correct values of the DNS domains and DNS servers (target IPs) in your on-premises location. This values are used by the Outbound Endpoints to forward DNS queries from AWS to your on-premises DNS servers.

## Target Architecture

![Architecture diagram](./images/architecture\_diagram.png)

### References

- AWS Reference Architecture - [Hybrid DNS Resolution with Amazon Route 53 Resolver Endpoints](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/hybrid-dns_route53-resolver-endpoint-ra.pdf)
- AWS Whitepaper - [Building a Scalable and Secure Multi-VPC AWS Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)
- AWS Documentation - [AWS PrivateLink for Amazon S3 interface endpoints](https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html#accessing-s3-interface-endpoints)
- AWS Blogs - [Secure hybrid access to Amazon S3 using AWS PrivateLink](https://aws.amazon.com/blogs/networking-and-content-delivery/secure-hybrid-access-to-amazon-s3-using-aws-privatelink/)

### Cleanup

Remember to clean up after your work is complete. You can do that by doing `terraform destroy`.

Note that this command will delete all the resources previously created by Terraform.

------

## Security

See [CONTRIBUTING](CONTRIBUTING.md) for more information.

## License

This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file.

------

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_endpoint_record"></a> [endpoint\_record](#module\_endpoint\_record) | ./modules/route53_record | n/a |
| <a name="module_hubspoke"></a> [hubspoke](#module\_hubspoke) | aws-ia/network-hubandspoke/aws | = 2.0.0 |
| <a name="module_spoke_vpcs"></a> [spoke\_vpcs](#module\_spoke\_vpcs) | aws-ia/vpc/aws | = 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy_attachment.s3_readonly_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.ssm_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.role_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_flowlogs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flowlogs_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.log_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_resolver_endpoint.inbound_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_endpoint.outbound_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_rule.forwarding_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule) | resource |
| [aws_route53_zone.private_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_security_group.endpoints_vpc_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_kms_logs_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_role_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_rolepolicy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to create the environment. | `string` | `"eu-west-2"` | no |
| <a name="input_forwarding_rules"></a> [forwarding\_rules](#input\_forwarding\_rules) | Forwarding rules to on-premises DNS servers. | `map(any)` | <pre>{<br>  "example-domain": {<br>    "domain_name": "example.com",<br>    "rule_type": "FORWARD",<br>    "target_ip": [<br>      "1.1.1.1",<br>      "2.2.2.2"<br>    ]<br>  },<br>  "test-domain": {<br>    "domain_name": "test.es",<br>    "rule_type": "FORWARD",<br>    "target_ip": [<br>      "1.1.1.1"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project Name, used as identifer when creating resources. | `string` | `"hubspoke-shared-services"` | no |
| <a name="input_on_premises_cidr"></a> [on\_premises\_cidr](#input\_on\_premises\_cidr) | On-premises CIDR block. | `string` | `"192.168.0.0/16"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create. | `any` | <pre>{<br>  "spoke-vpc-1": {<br>    "cidr_block": "10.0.0.0/24",<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "number_azs": 1,<br>    "tgw_subnets": [<br>      "10.0.0.192/28",<br>      "10.0.0.208/28",<br>      "10.0.0.224/28"<br>    ],<br>    "type": "spoke",<br>    "workload_subnets": [<br>      "10.0.0.0/26",<br>      "10.0.0.64/26",<br>      "10.0.0.128/26"<br>    ]<br>  },<br>  "spoke-vpc-2": {<br>    "cidr_block": "10.0.1.0/24",<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "number_azs": 1,<br>    "tgw_subnets": [<br>      "10.0.1.192/28",<br>      "10.0.1.208/28",<br>      "10.0.1.224/28"<br>    ],<br>    "type": "spoke",<br>    "workload_subnets": [<br>      "10.0.1.0/26",<br>      "10.0.1.64/26",<br>      "10.0.1.128/26"<br>    ]<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instances"></a> [ec2\_instances](#output\_ec2\_instances) | Instances created in each Spoke VPC. |
| <a name="output_private_hosted_zones"></a> [private\_hosted\_zones](#output\_private\_hosted\_zones) | Private Hosted Zones. |
| <a name="output_route53_resolver_endpoints"></a> [route53\_resolver\_endpoints](#output\_route53\_resolver\_endpoints) | Route 53 Resolver Endpoints. |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | Transit Gateway resources. |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | VPC endpoints created. |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | VPCs created. |
<!-- END_TF_DOCS -->