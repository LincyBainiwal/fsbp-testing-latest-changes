# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-event-notifications-configured.policy.hcl"
    ]
}

# Test 1: PASS - db-instance subscription with all required event categories
resource "aws_db_event_subscription" "pass_all_required_categories" {
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["maintenance", "configuration change", "failure"]
    enabled = true
  }
}

# Test 2: FAIL - db-instance subscription missing 'maintenance' category
resource "aws_db_event_subscription" "fail_missing_maintenance" {
  expect_failure = true
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["configuration change", "failure"]
    enabled = true
  }
}

# Test 3: FAIL - db-instance subscription missing 'configuration change' category
resource "aws_db_event_subscription" "fail_missing_config_change" {
  expect_failure = true
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["maintenance", "failure"]
    enabled = true
  }
}

# Test 4: FAIL - db-instance subscription missing 'failure' category
resource "aws_db_event_subscription" "fail_missing_failure" {
  expect_failure = true
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["maintenance", "configuration change"]
    enabled = true
  }
}

# Test 5: PASS - db-instance subscription with no event_categories specified
resource "aws_db_event_subscription" "fail_no_categories" {
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    enabled = true
  }
}

# Test 6: FAIL - db-instance subscription with all categories but enabled is false
resource "aws_db_event_subscription" "fail_disabled_subscription" {
  expect_failure = true
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["maintenance", "configuration change", "failure"]
    enabled = false
  }
}

# Test 7: PASS - unspecified source_type (defaults to all sources) with all required categories
resource "aws_db_event_subscription" "pass_unspecified_source_type" {
  attrs = {
    name = "rds-all-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    event_categories = ["maintenance", "configuration change", "failure"]
    enabled = true
  }
}

# Test 8: FAIL - unspecified source_type but missing required categories
resource "aws_db_event_subscription" "fail_unspecified_source_missing_categories" {
  expect_failure = true
  attrs = {
    name = "rds-all-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    event_categories = ["maintenance"]
    enabled = true
  }
}

# Test 9: PASS - subscription with different source_type (should be filtered out)
resource "aws_db_event_subscription" "pass_different_source_type_filtered" {
  attrs = {
    name = "rds-param-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-parameter-group"
    event_categories = ["configuration change"]
    enabled = true
  }
}

# Test 10: PASS - enabled defaults to true when not specified
resource "aws_db_event_subscription" "pass_enabled_default_true" {
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["maintenance", "configuration change", "failure"]
  }
}

# Test 11: PASS - subscription with extra event categories beyond required ones
resource "aws_db_event_subscription" "pass_extra_categories" {
  attrs = {
    name = "rds-instance-events"
    sns_topic = "arn:aws:sns:us-east-1:123456789012:rds-events"
    source_type = "db-instance"
    event_categories = ["maintenance", "configuration change", "failure", "availability", "backup"]
    enabled = true
  }
}
