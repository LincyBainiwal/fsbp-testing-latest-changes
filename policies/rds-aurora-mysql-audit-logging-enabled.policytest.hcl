# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-aurora-mysql-audit-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Aurora MySQL with audit logs export enabled
resource "aws_rds_cluster" "pass_audit_logging_enabled" {
    attrs = {
        cluster_identifier      = "aurora-cluster-demo"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        enabled_cloudwatch_logs_exports = ["audit"]
    }
}

# Test 2: FAIL - Aurora MySQL with audit logs export disabled
resource "aws_rds_cluster" "fail_audit_logging_disabled" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-no-audit"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        enabled_cloudwatch_logs_exports = []
    }
}

# Test 3: SKIP - Aurora PostgreSQL (filtered out by policy)
resource "aws_rds_cluster" "skip_aurora_postgresql" {
    attrs = {
        cluster_identifier      = "aurora-postgres-cluster"
        engine                  = "aurora-postgresql"
        engine_version          = "14.6"
        master_username         = "admin"
        master_password         = "password123"
    }
}

# Test 4: FAIL - Aurora MySQL with other logs export enabled
resource "aws_rds_cluster" "fail_audit_logging_disabled" {
    expect_failure = true
    attrs = {
        cluster_identifier      = "aurora-cluster-no-audit"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        enabled_cloudwatch_logs_exports = ["error", "general"]
    }
}

# Test 5: PASS - Aurora MySQL with multiple log exports enabled
resource "aws_rds_cluster" "pass_audit_logging_enabled" {
    attrs = {
        cluster_identifier      = "aurora-cluster-audit"
        engine                  = "aurora-mysql"
        engine_version          = "5.7.mysql_aurora.2.11.2"
        master_username         = "admin"
        master_password         = "password123"
        enabled_cloudwatch_logs_exports = ["audit", "general"]
    }
}

# Test 6: SKIP - Aurora PostgreSQL cluster with multiple log types including postgresql
resource "aws_rds_cluster" "pass_multiple_log_types" {
  attrs = {
    engine = "aurora-postgresql"
    enabled_cloudwatch_logs_exports = ["postgresql", "audit", "error"]
    cluster_identifier = "test-cluster-pass-2"
  }
}
