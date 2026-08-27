# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-cluster-event-notifications-configured.policy.hcl"
    ]
}

# Test 1: PASS - Subscription with both required categories and enabled
resource "aws_db_event_subscription" "pass_with_both_categories_enabled" {
  attrs = {
    source_type = "db-cluster"
    event_categories = ["maintenance", "failure"]
    enabled = true
  }
}

# Test 2: PASS - Subscription with both required categories and enabled not set (defaults to true)
resource "aws_db_event_subscription" "pass_with_both_categories_default_enabled" {
  attrs = {
    source_type = "db-cluster"
    event_categories = ["maintenance", "failure"]
  }
}

# Test 3: PASS - Subscription with all event categories including required ones
resource "aws_db_event_subscription" "pass_with_all_categories" {
  attrs = {
    source_type = "db-cluster"
    event_categories = ["maintenance", "failure", "notification", "configuration change"]
    enabled = true
  }
}

# Test 4: FAIL - Subscription with only maintenance category
resource "aws_db_event_subscription" "fail_missing_failure_category" {
  expect_failure = true
  attrs = {
    source_type = "db-cluster"
    event_categories = ["maintenance"]
    enabled = true
  }
}

# Test 5: FAIL - Subscription with only failure category
resource "aws_db_event_subscription" "fail_missing_maintenance_category" {
  expect_failure = true
  attrs = {
    source_type = "db-cluster"
    event_categories = ["failure"]
    enabled = true
  }
}

# Test 6: FAIL - Subscription with neither required category
resource "aws_db_event_subscription" "fail_missing_both_categories" {
  expect_failure = true
  attrs = {
    source_type = "db-cluster"
    event_categories = ["notification", "configuration change"]
    enabled = true
  }
}

# Test 7: FAIL - Subscription with both categories but disabled
resource "aws_db_event_subscription" "fail_disabled_subscription" {
  expect_failure = true
  attrs = {
    source_type = "db-cluster"
    event_categories = ["maintenance", "failure"]
    enabled = false
  }
}

# Test 8: PASS - No subscriptions
resource "aws_db_event_subscription" "pass_db_instance_filtered_out" {
  attrs = {}
}

# Test 9: PASS - No subscriptions
resource "aws_db_event_subscription" "pass_no_subscriptions" {
  attrs = {
    source_type = "db-cluster"
  }
}

# Test 10: No subscriptions (filtered out - db-instance not db-cluster)
resource "aws_db_event_subscription" "pass_db_instance_filtered_out" {
  attrs = {
    source_type = "db-instance"
  }
}