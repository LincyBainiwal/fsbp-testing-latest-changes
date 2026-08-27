# Copyright IBM Corp. 2026

policytest {
  targets = ["opensearch-audit-logging-enabled.policy.hcl"]
}

# PASS: Single AUDIT_LOGS block with enabled=true
resource "aws_opensearch_domain" "pass_single_audit_log_enabled" {
  attrs = {
    domain_name    = "pass-single-audit"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:audit"
        log_type                 = "AUDIT_LOGS"
        enabled                  = true
      }
    ]
  }
}

# PASS: Multiple log types including AUDIT_LOGS enabled — other log types are valid alongside
resource "aws_opensearch_domain" "pass_multiple_log_types_with_audit" {
  attrs = {
    domain_name    = "pass-multi-log"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:slow"
        log_type                 = "INDEX_SLOW_LOGS"
        enabled                  = true
      },
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:audit"
        log_type                 = "AUDIT_LOGS"
        enabled                  = true
      }
    ]
  }
}

# FAIL: AUDIT_LOGS block with enabled omitted (defaults to false)
resource "aws_opensearch_domain" "fail_audit_log_enabled_omitted" {
  expect_failure = true
  attrs = {
    domain_name    = "fail-audit-enabled-omitted"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:audit"
        log_type                 = "AUDIT_LOGS"
      }
    ]
  }
}

# FAIL: Empty log_publishing_options list
resource "aws_opensearch_domain" "fail_empty_log_publishing_options" {
  expect_failure = true
  attrs = {
    domain_name    = "fail-empty-log-options"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = []
  }
}

# FAIL: log_publishing_options is absent
resource "aws_opensearch_domain" "fail_no_log_publishing_options" {
  expect_failure = true
  attrs = {
    domain_name    = "fail-no-log-options"
    engine_version = "OpenSearch_2.11"
  }
}

# FAIL: AUDIT_LOGS block exists but enabled=false
resource "aws_opensearch_domain" "fail_audit_log_disabled" {
  expect_failure = true
  attrs = {
    domain_name    = "fail-audit-disabled"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:audit"
        log_type                 = "AUDIT_LOGS"
        enabled                  = false
      }
    ]
  }
}

# FAIL: Only non-AUDIT_LOGS log type
resource "aws_opensearch_domain" "fail_only_index_slow_logs" {
  expect_failure = true
  attrs = {
    domain_name    = "fail-only-index-slow"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:slow"
        log_type                 = "INDEX_SLOW_LOGS"
        enabled                  = true
      }
    ]
  }
}

# FAIL: Multiple non-audit log types, none have AUDIT_LOGS
resource "aws_opensearch_domain" "fail_multiple_non_audit_log_types" {
  expect_failure = true
  attrs = {
    domain_name    = "fail-multi-non-audit"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:slow-index"
        log_type                 = "INDEX_SLOW_LOGS"
        enabled                  = true
      },
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:slow-search"
        log_type                 = "SEARCH_SLOW_LOGS"
        enabled                  = true
      }
    ]
  }
}

# PASS: Two AUDIT_LOGS entries — one enabled=true, one enabled=false
#       At least one enabled AUDIT_LOGS entry exists so this should pass
resource "aws_opensearch_domain" "pass_one_enabled_one_disabled_audit" {
  attrs = {
    domain_name    = "pass-mixed-audit-enabled"
    engine_version = "OpenSearch_2.11"
    log_publishing_options = [
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:audit-enabled"
        log_type                 = "AUDIT_LOGS"
        enabled                  = true
      },
      {
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:audit-disabled"
        log_type                 = "AUDIT_LOGS"
        enabled                  = false
      }
    ]
  }
}