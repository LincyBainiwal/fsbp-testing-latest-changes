# Copyright IBM Corp. 2026

policytest {
    targets = [
        "neptune-cluster-cloudwatch-log-export-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Audit logging enabled (only audit)
resource "aws_neptune_cluster" "pass_audit_only" {
  attrs = {
    cluster_identifier              = "neptune-audit-only"
    enable_cloudwatch_logs_exports  = ["audit"]
    engine                          = "neptune"
  }
}

# Test 2: PASS - Audit logging enabled with other log type
resource "aws_neptune_cluster" "pass_audit_and_other" {
  attrs = {
    cluster_identifier              = "neptune-audit-other"
    enable_cloudwatch_logs_exports  = ["audit", "slowquery"]
    engine                          = "neptune"
  }
}

# Test 3: PASS - Audit logging enabled (other log first, then audit)
resource "aws_neptune_cluster" "pass_other_then_audit" {
  attrs = {
    cluster_identifier              = "neptune-other-audit"
    enable_cloudwatch_logs_exports  = ["slowquery", "audit"]
    engine                          = "neptune"
  }
}

# Test 4: FAIL - Only other logging enabled (no audit)
resource "aws_neptune_cluster" "fail_other_only" {
  expect_failure = true
  attrs = {
    cluster_identifier              = "neptune-other-only"
    enable_cloudwatch_logs_exports  = ["slowquery"]
    engine                          = "neptune"
  }
}

# Test 5: FAIL - Empty CloudWatch logs exports
resource "aws_neptune_cluster" "fail_empty_logs" {
  expect_failure = true
  attrs = {
    cluster_identifier              = "neptune-empty-logs"
    enable_cloudwatch_logs_exports  = []
    engine                          = "neptune"
  }
}

# Test 6: FAIL - Missing enable_cloudwatch_logs_exports (defaults to empty list)
resource "aws_neptune_cluster" "fail_missing_logs" {
  expect_failure = true
  attrs = {
    cluster_identifier              = "neptune-missing-logs"
    engine                          = "neptune"
  }
}
