# Copyright IBM Corp. 2026

# RDS DB clusters should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-cluster-encrypted-at-rest-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "encrypted_at_rest" {
    enforcement_level = input.rds-cluster-encrypted-at-rest-enforcement-level
    locals {
        engine_mode = core::try(attrs.engine_mode, "provisioned")
        provisioned_condition = local.engine_mode == "provisioned" && core::try(attrs.storage_encrypted, false)
        serverless_condition = local.engine_mode == "serverless" && core::try(attrs.storage_encrypted, true)
    }

    enforce {
        condition = local.provisioned_condition || local.serverless_condition
        error_message = "RDS DB clusters should be encrypted at rest"
    }
}
