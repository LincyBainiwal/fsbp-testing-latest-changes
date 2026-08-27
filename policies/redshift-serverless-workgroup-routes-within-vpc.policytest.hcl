# Copyright IBM Corp. 2026

policytest {
  targets = [
    "redshift-serverless-workgroup-routes-within-vpc.policy.hcl"
  ]
}

# Test 1: Pass - enhanced_vpc_routing explicitly set to true
resource "aws_redshiftserverless_workgroup" "compliant" {
  attrs = {
    namespace_name        = "test-namespace"
    workgroup_name        = "test-workgroup"
    enhanced_vpc_routing  = true
    subnet_ids            = ["subnet-12345", "subnet-67890", "subnet-abcde"]
    security_group_ids    = ["sg-12345"]
  }
}

# Test 2: Fail - enhanced_vpc_routing explicitly set to false
resource "aws_redshiftserverless_workgroup" "non_compliant" {
  expect_failure = true
  attrs = {
    namespace_name        = "test-namespace"
    workgroup_name        = "test-workgroup"
    enhanced_vpc_routing  = false
    subnet_ids            = ["subnet-12345", "subnet-67890", "subnet-abcde"]
    security_group_ids    = ["sg-12345"]
  }
}

# Test 3: Fail - enhanced_vpc_routing attribute not specified (defaults to false)
resource "aws_redshiftserverless_workgroup" "missing_attribute" {
  expect_failure = true
  attrs = {
    namespace_name     = "test-namespace"
    workgroup_name     = "test-workgroup"
    subnet_ids         = ["subnet-12345", "subnet-67890", "subnet-abcde"]
    security_group_ids = ["sg-12345"]
  }
}