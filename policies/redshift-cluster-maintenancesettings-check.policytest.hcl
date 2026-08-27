# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-cluster-maintenancesettings-check.policy.hcl"
    ]
}

# Test 1: Pass - Explicit true
resource "aws_redshift_cluster" "pass_explicit_true" {
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = true
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 2: Fail - Explicit false
resource "aws_redshift_cluster" "fail_explicit_false" {
  expect_failure = true
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = false
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 3: Pass - Default value (attribute not specified)
resource "aws_redshift_cluster" "pass_default_value" {
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 4: Pass - Explicit automated_snapshot_retention_period > 0
resource "aws_redshift_cluster" "pass_snapshot_retention_positive" {
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = true
    automated_snapshot_retention_period = 7
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 5: Fail - automated_snapshot_retention_period = 0
resource "aws_redshift_cluster" "fail_snapshot_retention_zero" {
  expect_failure = true
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = true
    automated_snapshot_retention_period = 0
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 6: Pass - Default automated_snapshot_retention_period (not specified, defaults to 1)
resource "aws_redshift_cluster" "pass_snapshot_retention_default" {
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = true
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 7: Fail - Both conditions fail (version_upgrade false and snapshot retention 0)
resource "aws_redshift_cluster" "fail_both_conditions" {
  expect_failure = true
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = false
    automated_snapshot_retention_period = 0
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 8: Pass - With preferred_maintenance_window specified
resource "aws_redshift_cluster" "pass_with_maintenance_window" {
  attrs = {
    cluster_identifier = "my-redshift-cluster"
    node_type = "dc2.large"
    allow_version_upgrade = true
    automated_snapshot_retention_period = 5
    preferred_maintenance_window = "sun:05:00-sun:06:00"
    master_username = "admin"
    database_name = "mydb"
  }
}