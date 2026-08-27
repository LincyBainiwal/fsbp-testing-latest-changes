# Copyright IBM Corp. 2026

policytest {
  targets = [
    "redshift-serverless-workgroup-no-public-access.policy.hcl"
  ]
}
# Test 1: Pass - publicly_accessible explicitly set to false
resource "aws_redshiftserverless_workgroup" "compliant" {
  attrs = {
    namespace_name       = "test-namespace"
    workgroup_name       = "test-workgroup"
    publicly_accessible  = false
    base_capacity        = 32
  }
}

# Test 2: Pass - publicly_accessible omitted (defaults to false)
resource "aws_redshiftserverless_workgroup" "default_secure" {
  attrs = {
    namespace_name       = "test-namespace"
    workgroup_name       = "test-workgroup"
    base_capacity        = 32
  }
}

# Test 3: Fail - publicly_accessible set to true
resource "aws_redshiftserverless_workgroup" "non_compliant" {
  expect_failure = true
  attrs = {
    namespace_name       = "test-namespace"
    workgroup_name       = "test-workgroup"
    publicly_accessible  = true
    base_capacity        = 32
  }
}