# Copyright IBM Corp. 2026

# Redshift clusters should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-cluster-kms-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "redshift-cluster-kms-enabled-kms-key-arns" {
    type = string
    default = ""
}

resource_policy "aws_redshift_cluster" "kms-enabled" {
    enforcement_level = input.redshift-cluster-kms-enabled-enforcement-level
    locals {
        has_encryption = core::try(attrs.encrypted, false)
        kms_key_arn = local.has_encryption ? core::try(attrs.kms_key_id, "") : ""
        kms_key_arns_provided = input.redshift-cluster-kms-enabled-kms-key-arns != ""
        valid_kms_key_arn = local.kms_key_arns_provided ? (local.kms_key_arn != "" ? core::contains(core::split(",", input.redshift-cluster-kms-enabled-kms-key-arns), local.kms_key_arn) : true) : true
    }

    enforce {
        condition = local.has_encryption && local.valid_kms_key_arn
        error_message = "Redshift cluster either does not have encryption enabled or uses invalid KMS key"
    }
}
