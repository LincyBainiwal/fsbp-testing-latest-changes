# Copyright IBM Corp. 2026

# Neptune DB clusters should have deletion protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "neptune-cluster-deletion-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_neptune_cluster" "deletion-protection-enabled" {
    enforcement_level = input.neptune-cluster-deletion-protection-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.deletion_protection, false)
        error_message = "The Neptune cluster does not have deletion protection enabled"
    }
}