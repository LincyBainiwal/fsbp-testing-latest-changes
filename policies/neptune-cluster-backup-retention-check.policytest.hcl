# Copyright IBM Corp. 2026

policytest {
    targets = [
        "neptune-cluster-backup-retention-check.policy.hcl"
    ]
}

# Test 1: PASS - Backup retention period equals default minimum (7 days)
resource "aws_neptune_cluster" "pass_retention_equals_default" {
  attrs = {
    cluster_identifier      = "neptune-retention-7"
    backup_retention_period = 7
    engine                  = "neptune"
  }
}

# Test 2: PASS - Backup retention period greater than default minimum (14 days)
resource "aws_neptune_cluster" "pass_retention_14_days" {
  attrs = {
    cluster_identifier      = "neptune-retention-14"
    backup_retention_period = 14
    engine                  = "neptune"
  }
}

# Test 3: PASS - Backup retention period at maximum (35 days)
resource "aws_neptune_cluster" "pass_retention_max" {
  attrs = {
    cluster_identifier      = "neptune-retention-35"
    backup_retention_period = 35
    engine                  = "neptune"
  }
}

# Test 4: FAIL - Backup retention period less than default minimum (6 days)
resource "aws_neptune_cluster" "fail_retention_6_days" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "neptune-retention-6"
    backup_retention_period = 6
    engine                  = "neptune"
  }
}

# Test 5: FAIL - Backup retention period much less than default minimum (1 day)
resource "aws_neptune_cluster" "fail_retention_1_day" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "neptune-retention-1"
    backup_retention_period = 1
    engine                  = "neptune"
  }
}

# Test 6: FAIL - Backup retention period is 0
resource "aws_neptune_cluster" "fail_retention_0" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "neptune-retention-0"
    backup_retention_period = 0
    engine                  = "neptune"
  }
}

# Test 7: FAIL - Missing backup_retention_period (defaults to 1, less than default minimum 7)
resource "aws_neptune_cluster" "fail_missing_retention" {
  expect_failure = true
  attrs = {
    cluster_identifier = "neptune-missing-retention"
    engine             = "neptune"
  }
}
