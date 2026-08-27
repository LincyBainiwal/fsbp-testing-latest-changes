# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-default-admin-check.policy.hcl"
    ]
}

# Test 1: FAIL - Default username "awsuser" (primary violation)
resource "aws_redshift_cluster" "fail_default_awsuser" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-default"
    node_type = "dc2.large"
    master_username = "awsuser"
    database_name = "mydb"
  }
}

# Test 2: FAIL - Missing master_username (defaults to awsuser)
resource "aws_redshift_cluster" "fail_missing_username" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-missing"
    node_type = "dc2.large"
    database_name = "mydb"
  }
}