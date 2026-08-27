# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-backup-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Retention period 1 day (minimum allowed)
resource "aws_redshift_cluster" "pass_1day" {
  attrs = {
    cluster_identifier = "test-cluster-1day"
    node_type = "dc2.large"
    automated_snapshot_retention_period = 1
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 2: PASS - Retention period 7 days (within range)
resource "aws_redshift_cluster" "pass_7days" {
  attrs = {
    cluster_identifier = "test-cluster-7days"
    node_type = "dc2.large"
    automated_snapshot_retention_period = 7
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 3: PASS - Retention period 35 days (maximum allowed)
resource "aws_redshift_cluster" "pass_35days" {
  attrs = {
    cluster_identifier = "test-cluster-35days"
    node_type = "dc2.large"
    automated_snapshot_retention_period = 35
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 4: FAIL - Automated snapshots disabled (retention = 0)
resource "aws_redshift_cluster" "fail_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-disabled"
    node_type = "dc2.large"
    automated_snapshot_retention_period = 0
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 5: FAIL - Retention period 36 days (exceeds maximum)
resource "aws_redshift_cluster" "fail_36days" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-36days"
    node_type = "dc2.large"
    automated_snapshot_retention_period = 36
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 6: FAIL - Retention period 50 days (exceeds maximum)
resource "aws_redshift_cluster" "fail_50days" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-50days"
    node_type = "dc2.large"
    automated_snapshot_retention_period = 50
    master_username = "admin"
    database_name = "mydb"
  }
}