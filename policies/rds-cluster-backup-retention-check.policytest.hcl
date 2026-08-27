# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-backup-retention-check.policy.hcl"
    ]
}

# Test 1: PASS - Backup retention period equals default minimum (7 days)
resource "aws_rds_cluster" "pass_cluster_retention_equals_default" {
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
    backup_retention_period = 7
  }
}

# Test 2: PASS - Backup retention period greater than default minimum (14 days)
resource "aws_rds_cluster" "pass_cluster_retention_14_days" {
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
    backup_retention_period = 14
  }
}

# Test 3: PASS - Backup retention period at maximum (35 days)
resource "aws_rds_cluster" "pass_cluster_retention_max" {
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
    backup_retention_period = 35
  }
}

# Test 4: FAIL - Backup retention period less than default minimum (6 days)
resource "aws_rds_cluster" "fail_cluster_retention_6_days" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
    backup_retention_period = 6
  }
}

# Test 5: FAIL - Backup retention period much less than default minimum (1 day)
resource "aws_rds_cluster" "fail_cluster_retention_1_day" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
    backup_retention_period = 1
  }
}

# Test 6: FAIL - Backup retention period is 0
resource "aws_rds_cluster" "fail_cluster_retention_0" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
    backup_retention_period = 0
  }
}

# Test 7: FAIL - Missing backup_retention_period (defaults to 1, less than default minimum 7)
resource "aws_rds_cluster" "fail_cluster_missing_retention" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "aurora-cluster-custom"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.11.2"
    master_username         = "dbadmin"
    master_password         = "password123"
  }
}
