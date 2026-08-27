# Copyright IBM Corp. 2026

# RDS DB instances should have encryption at-rest enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-storage-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "storage_encrypted" {
    enforcement_level = input.rds-storage-encrypted-enforcement-level
    enforce {
        condition = core::try(attrs.storage_encrypted, false) == true
        error_message = "RDS DB instances should have encryption at-rest enabled"
    }
}
