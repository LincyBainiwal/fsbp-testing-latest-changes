# Copyright IBM Corp. 2026

# ElastiCache clusters should not use the default subnet group

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticache-subnet-group-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticache_subnet_group" "default-sg" {
    enforcement_level = input.elasticache-subnet-group-check-enforcement-level
    enforce {
        condition = core::try(attrs.name, "default") != "default"
        error_message = "ElastiCache cluster uses the default subnet group"
    }
}

resource_policy "aws_elasticache_cluster" "default-subnet-group" {
    enforcement_level = input.elasticache-subnet-group-check-enforcement-level
    enforce {
        condition     = core::try(attrs.subnet_group_name, "default") != "default"
        error_message = "ElastiCache cluster uses the default subnet group"
    }
}

# aws_elasticache_replication_group also has a subnet_group_name attribute 
resource_policy "aws_elasticache_replication_group" "default-subnet-group" {
    enforcement_level = input.elasticache-subnet-group-check-enforcement-level
    enforce {
        condition     = core::try(attrs.subnet_group_name, "default") != "default"
        error_message = "ElastiCache replication group uses the default subnet group. Set subnet_group_name to a custom subnet group."
    }
}