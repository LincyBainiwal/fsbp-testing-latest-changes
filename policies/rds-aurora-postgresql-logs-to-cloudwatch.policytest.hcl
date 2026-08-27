# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-aurora-postgresql-logs-to-cloudwatch.policy.hcl"
    ]
}

# Test 1: PASS - Aurora PostgreSQL cluster with postgresql logs enabled
resource "aws_rds_cluster" "pass_postgresql_logs_enabled" {
  attrs = {
    engine = "aurora-postgresql"
    enabled_cloudwatch_logs_exports = ["postgresql"]
    cluster_identifier = "test-cluster-pass"
  }
}

# Test 2: FAIL - Aurora PostgreSQL cluster without enabled_cloudwatch_logs_exports
resource "aws_rds_cluster" "fail_no_logs_exports" {
  expect_failure = true
  attrs = {
    engine = "aurora-postgresql"
    cluster_identifier = "test-cluster-fail-1"
  }
}

# Test 3: FAIL - Aurora PostgreSQL cluster with logs but postgresql not included
resource "aws_rds_cluster" "fail_postgresql_not_included" {
  expect_failure = true
  attrs = {
    engine = "aurora-postgresql"
    enabled_cloudwatch_logs_exports = ["audit", "error"]
    cluster_identifier = "test-cluster-fail-2"
  }
}

# Test 4: FAIL - Aurora PostgreSQL cluster with empty log exports list
resource "aws_rds_cluster" "fail_empty_logs_exports" {
  expect_failure = true
  attrs = {
    engine = "aurora-postgresql"
    enabled_cloudwatch_logs_exports = []
    cluster_identifier = "test-cluster-fail-3"
  }
}

# Test 5: PASS - Aurora PostgreSQL cluster with multiple log types including postgresql
resource "aws_rds_cluster" "pass_multiple_log_types" {
  attrs = {
    engine = "aurora-postgresql"
    enabled_cloudwatch_logs_exports = ["postgresql", "audit", "error"]
    cluster_identifier = "test-cluster-pass-2"
  }
}

# Test 6: SKIP - Aurora MySQL cluster (filtered out by engine check)
resource "aws_rds_cluster" "skip_aurora_mysql" {
  attrs = {
    engine = "aurora-mysql"
    enabled_cloudwatch_logs_exports = []
    cluster_identifier = "mysql-cluster"
  }
}
