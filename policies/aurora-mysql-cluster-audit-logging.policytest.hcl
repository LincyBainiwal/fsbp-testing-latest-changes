# Copyright IBM Corp. 2026

policytest {
    targets = [
        "aurora-mysql-cluster-audit-logging.policy.hcl"
    ]
}

# Test 1: PASS - Aurora MySQL cluster with proper audit logging configuration
resource "aws_rds_cluster" "pass_complete_audit_config" {
  attrs = {
    engine = "aurora-mysql"
    db_cluster_parameter_group_name = "aurora-mysql-audit-enabled"
    enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  }
}

resource "aws_rds_cluster_parameter_group" "audit_enabled" {
  skip = true
  attrs = {
    name = "aurora-mysql-audit-enabled"
    family = "aurora-mysql8.0"
    parameter = [
      {
        name = "server_audit_logging"
        value = "1"
      },
      {
        name = "server_audit_events"
        value = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML"
      }
    ]
  }
}

# Test 2: FAIL - Aurora MySQL cluster without parameter group
resource "aws_rds_cluster" "fail_no_parameter_group" {
  expect_failure = true
  attrs = {
    engine = "aurora-mysql"
    enabled_cloudwatch_logs_exports = ["audit"]
  }
}

# Test 3: FAIL - Aurora MySQL cluster without CloudWatch audit log export
resource "aws_rds_cluster" "fail_no_cloudwatch_export" {
  expect_failure = true
  attrs = {
    engine = "aurora-mysql"
    db_cluster_parameter_group_name = "aurora-mysql-audit-enabled-no-export"
    enabled_cloudwatch_logs_exports = ["error", "general"]
  }
}

resource "aws_rds_cluster_parameter_group" "audit_enabled_no_export" {
  skip = true
  attrs = {
    name = "aurora-mysql-audit-enabled-no-export"
    family = "aurora-mysql8.0"
    parameter = [
      {
        name = "server_audit_logging"
        value = "1"
      },
      {
        name = "server_audit_events"
        value = "CONNECT,QUERY"
      }
    ]
  }
}

# Test 4: FAIL - Aurora MySQL cluster with audit logging disabled in parameter group
resource "aws_rds_cluster" "fail_audit_logging_disabled" {
  expect_failure = true
  attrs = {
    engine = "aurora-mysql"
    db_cluster_parameter_group_name = "aurora-mysql-no-audit"
    enabled_cloudwatch_logs_exports = ["audit"]
  }
}

resource "aws_rds_cluster_parameter_group" "no_audit" {
  skip = true
  attrs = {
    name = "aurora-mysql-no-audit"
    family = "aurora-mysql8.0"
    parameter = [
      {
        name = "server_audit_logging"
        value = "0"
      },
      {
        name = "server_audit_events"
        value = "CONNECT"
      }
    ]
  }
}

# Test 5: FAIL - Aurora MySQL cluster with empty audit events
resource "aws_rds_cluster" "fail_empty_audit_events" {
  expect_failure = true
  attrs = {
    engine = "aurora-mysql"
    db_cluster_parameter_group_name = "aurora-mysql-empty-events"
    enabled_cloudwatch_logs_exports = ["audit"]
  }
}

resource "aws_rds_cluster_parameter_group" "empty_events" {
  skip = true
  attrs = {
    name = "aurora-mysql-empty-events"
    family = "aurora-mysql8.0"
    parameter = [
      {
        name = "server_audit_logging"
        value = "1"
      },
      {
        name = "server_audit_events"
        value = ""
      }
    ]
  }
}

# Test 6: SKIP - Non-Aurora MySQL cluster (aurora-postgresql)
resource "aws_rds_cluster" "skip_aurora_postgresql" {
  attrs = {
    engine = "aurora-postgresql"
    db_cluster_parameter_group_name = "aurora-pg-default"
  }
}

# Test 7: SKIP - Non-Aurora MySQL parameter group family
resource "aws_rds_cluster_parameter_group" "skip_non_aurora_mysql_family" {
  attrs = {
    name = "aurora-pg-params"
    family = "aurora-postgresql14"
    parameter = []
  }
}

# Test 8: FAIL - Aurora MySQL cluster referencing non-existent parameter group
resource "aws_rds_cluster" "fail_missing_parameter_group_reference" {
  expect_failure = true
  attrs = {
    engine = "aurora-mysql"
    db_cluster_parameter_group_name = "non-existent-pg"
    enabled_cloudwatch_logs_exports = ["audit"]
  }
}

# Test 9: PASS - Aurora MySQL 5.7 with proper configuration
resource "aws_rds_cluster" "pass_aurora_mysql_57" {
  attrs = {
    engine = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.11.2"
    db_cluster_parameter_group_name = "aurora-mysql57-audit"
    enabled_cloudwatch_logs_exports = ["audit"]
  }
}

resource "aws_rds_cluster_parameter_group" "mysql57_audit" {
  skip = true
  attrs = {
    name = "aurora-mysql57-audit"
    family = "aurora-mysql5.7"
    parameter = [
      {
        name = "server_audit_logging"
        value = "1"
      },
      {
        name = "server_audit_events"
        value = "CONNECT,QUERY_DDL,QUERY_DML"
      }
    ]
  }
}
