# Copyright IBM Corp. 2026

# Amazon Redshift clusters should prohibit public access

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-cluster-public-access-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_redshift_cluster" "public_access_check" {
    enforcement_level = input.redshift-cluster-public-access-check-enforcement-level
    enforce {
        condition = core::try(attrs.publicly_accessible, false) == false
        error_message = "Redshift cluster is publicly accessible"
    }
}