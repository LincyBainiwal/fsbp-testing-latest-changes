# Copyright IBM Corp. 2026

policytest {
    targets = [
        "opensearch-logs-to-cloudwatch.policy.hcl"
    ]
}

# Test 1: PASS - ES_APPLICATION_LOGS enabled explicitly with valid CloudWatch Log Group ARN
resource "aws_opensearch_domain" "pass_explicit_enabled" {
  attrs = {
    domain_name = "compliant-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/compliant-domain"
      }
    ]
  }
}

# Test 2: PASS - ES_APPLICATION_LOGS with enabled attribute omitted (defaults to true)
resource "aws_opensearch_domain" "pass_enabled_omitted" {
  attrs = {
    domain_name = "compliant-default-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/compliant-default"
      }
    ]
  }
}

# Test 3: PASS - Multiple log types including ES_APPLICATION_LOGS properly configured
resource "aws_opensearch_domain" "pass_multiple_log_types" {
  attrs = {
    domain_name = "multiple-logs-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        log_type = "INDEX_SLOW_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/index-slow"
      },
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/application"
      },
      {
        log_type = "SEARCH_SLOW_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/search-slow"
      }
    ]
  }
}

# Test 4: FAIL - Empty log_publishing_options array (no logs configured)
resource "aws_opensearch_domain" "fail_empty_logging" {
  expect_failure = true
  attrs = {
    domain_name = "no-logging-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = []
  }
}

# Test 5: FAIL - log_publishing_options configured but no ES_APPLICATION_LOGS
resource "aws_opensearch_domain" "fail_no_application_logs" {
  expect_failure = true
  attrs = {
    domain_name = "no-app-logs-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        log_type = "INDEX_SLOW_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/index-slow"
      },
      {
        log_type = "SEARCH_SLOW_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/search-slow"
      }
    ]
  }
}

# Test 6: FAIL - ES_APPLICATION_LOGS configured but explicitly disabled
resource "aws_opensearch_domain" "fail_explicitly_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "disabled-logging-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = false
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/opensearch/disabled"
      }
    ]
  }
}

# Test 7: FAIL - ES_APPLICATION_LOGS enabled but missing cloudwatch_log_group_arn
resource "aws_opensearch_domain" "fail_missing_log_group_arn" {
  expect_failure = true
  attrs = {
    domain_name = "missing-arn-domain"
    engine_version = "OpenSearch_2.5"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
        cloudwatch_log_group_arn = ""
      }
    ]
  }
}

# Test 8: FAIL - Empty log_publishing_options array
resource "aws_opensearch_domain" "fail_no_log_options" {
  expect_failure = true
  attrs = {
    domain_name = "empty-logs-domain"
    engine_version = "OpenSearch_2.5"
  }
}
