# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-iam-authentication-enabled.policy.hcl"
    ]
}

# Test 1: PASS - IAM authentication enabled
resource "aws_rds_cluster" "pass_iam_auth_enabled" {
  attrs = {
    cluster_identifier = "compliant-cluster"
    engine = "aurora-mysql"
    iam_database_authentication_enabled = true
  }
}

# Test 2: FAIL - IAM authentication explicitly disabled
resource "aws_rds_cluster" "fail_iam_auth_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "non-compliant-cluster"
    engine = "aurora-mysql"
    iam_database_authentication_enabled = false
  }
}

# Test 3: FAIL - IAM authentication not set (defaults to false)
resource "aws_rds_cluster" "fail_iam_auth_not_set" {
  expect_failure = true
  attrs = {
    cluster_identifier = "default-cluster"
    engine = "aurora-postgresql"
  }
}
