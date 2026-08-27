# Copyright IBM Corp. 2026

policytest {
  targets = ["vpc-network-acl-unused-check.policy.hcl"]
}

# Scenario 1: Network ACL with direct subnet associations via subnet_ids (PASS)
resource "aws_network_acl" "pass_direct_subnet_associations" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111", "subnet-22222222"]
    tags = {
      Name = "test-nacl"
    }
  }
}

# Scenario 3: Unused network ACL with no subnet associations (FAIL)
resource "aws_network_acl" "fail_no_associations" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = null
    tags = {
      Name = "unused-nacl"
    }
  }
}

# Scenario 4: Network ACL with empty subnet_ids list (FAIL)
resource "aws_network_acl" "fail_empty_subnet_ids" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = []
    tags = {
      Name = "empty-nacl"
    }
  }
}

# Scenario 8: Network ACL with multiple subnet associations (PASS)
resource "aws_network_acl" "pass_multiple_subnets" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
    tags = {
      Name = "multi-subnet-nacl"
    }
  }
}

# Additional test: Network ACL with single subnet (PASS)
resource "aws_network_acl" "pass_single_subnet" {
  attrs = {
    vpc_id     = "vpc-12345678"
    subnet_ids = ["subnet-11111111"]
    tags = {
      Name = "single-subnet-nacl"
    }
  }
}

# Additional test: Network ACL with subnet_ids attribute absent entirely (FAIL)
# core::try(..., false) should catch this and return false
resource "aws_network_acl" "fail_missing_subnet_ids_attr" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    tags = {
      Name = "no-subnet-attr-nacl"
    }
  }
}