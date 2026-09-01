# Copyright IBM Corp. 2026

policytest {
  targets = ["vpc-network-acl-unused-check.policy.hcl"]
}

# --------------- PASS cases ---------------

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

# Scenario 2: Network ACL with multiple subnet associations (PASS)
resource "aws_network_acl" "pass_multiple_subnets" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
    tags = {
      Name = "multi-subnet-nacl"
    }
  }
}

# Scenario 3: Network ACL with single subnet (PASS)
resource "aws_network_acl" "pass_single_subnet" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111"]
    tags = {
      Name = "single-subnet-nacl"
    }
  }
}

# Scenario 4: Default network ACL with no subnet associations (PASS — out of scope)
# aws_default_network_acl is not evaluated by this policy. Default NACLs are
# automatically associated with every subnet that has no explicit NACL, so
# they are never "unused" by definition. The policy intentionally ignores them.
resource "aws_default_network_acl" "pass_default_no_associations" {
  attrs = {
    default_network_acl_id = "acl-default123"
    subnet_ids = null
    tags = {
      Name = "default-nacl"
    }
  }
}

# Scenario 5: Default network ACL with associations (PASS — out of scope)
resource "aws_default_network_acl" "pass_default_with_associations" {
  attrs = {
    default_network_acl_id = "acl-default123"
    subnet_ids = ["subnet-11111111", "subnet-22222222"]
    tags = {
      Name = "default-nacl"
    }
  }
}

# --------------- FAIL cases ---------------

# Scenario 6: Unused network ACL with null subnet_ids (FAIL)
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

# Scenario 7: Network ACL with empty subnet_ids list (FAIL)
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