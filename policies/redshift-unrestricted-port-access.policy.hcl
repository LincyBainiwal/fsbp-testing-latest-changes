# Copyright IBM Corp. 2026

# Redshift security groups should allow ingress on the cluster port only from restricted origins
# This control checks whether a security group associated with an Amazon Redshift cluster has ingress rules that permit access to the cluster port from the internet (0.0.0.0/0 or ::/0). The control fails if the security group ingress rules permit access to the cluster port from the internet.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-unrestricted-port-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_redshift_cluster" "unrestricted-port-access" {
    enforcement_level = input.redshift-unrestricted-port-access-enforcement-level
    locals {
        cluster_sgs = core::try(attrs.vpc_security_group_ids, [])
        
        # Flatten all ingress rules from all security groups into a single list
        redshift_all_ingress_rules = core::length(local.cluster_sgs) > 0 ? core::flatten([
            for sg_id in local.cluster_sgs : core::getresources("aws_vpc_security_group_ingress_rule", {
                security_group_id = sg_id
            })
        ]) : []

        redshift_port = core::try(attrs.port, 5439)
        
        # Check if any rule allows unrestricted access to the Redshift port
        has_unrestricted_access = core::length(local.redshift_all_ingress_rules) > 0 ? core::contains([
            for sg_id in local.redshift_all_ingress_rules : (
                # check if port is a redshift port
                ((core::try(sg_id.ip_protocol, "-1") != "-1") ? (core::try(sg_id.from_port, 1115) <= local.redshift_port && core::try(sg_id.to_port, 65535) >= local.redshift_port) : true)
                &&
                # check if cidr is 0.0.0.0/0 or ::/0 - unrestricted access
                (core::try(sg_id.cidr_ipv4, "") == "0.0.0.0/0" || core::try(sg_id.cidr_ipv6, "") == "::/0")
            )
        ], true) : false

    }
    enforce {
        condition = !local.has_unrestricted_access
        error_message = "Redshift cluster has unrestricted access to port"
    }
}