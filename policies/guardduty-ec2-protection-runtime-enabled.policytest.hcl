# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-ec2-protection-runtime-enabled.policy.hcl"
    ]
}

# Test 1: PASS - RUNTIME_MONITORING enabled with EC2_AGENT_MANAGEMENT enabled
resource "aws_guardduty_detector_feature" "pass_runtime_monitoring_with_ec2_agent" {
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 2: FAIL - RUNTIME_MONITORING disabled
resource "aws_guardduty_detector_feature" "fail_runtime_monitoring_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    status = "DISABLED"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 3: FAIL - RUNTIME_MONITORING enabled but EC2_AGENT_MANAGEMENT disabled
resource "aws_guardduty_detector_feature" "fail_ec2_agent_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        status = "DISABLED"
      }
    ]
  }
}

# Test 4: FAIL - RUNTIME_MONITORING enabled but no additional_configuration
resource "aws_guardduty_detector_feature" "fail_no_additional_config" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
  }
}

# Test 5: FAIL - RUNTIME_MONITORING enabled with empty additional_configuration
resource "aws_guardduty_detector_feature" "fail_empty_additional_config" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = []
  }
}

# Test 6: SKIP - Different feature type (S3_DATA_EVENTS) - should be filtered out
resource "aws_guardduty_detector_feature" "skip_other_feature_types" {
  attrs = {
    detector_id = "abc123"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
  }
}

# Test 7: PASS - Organization RUNTIME_MONITORING enabled with EC2_AGENT_MANAGEMENT enabled
resource "aws_guardduty_organization_configuration_feature" "pass_org_runtime_monitoring_with_ec2_agent" {
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 8: FAIL - Organization RUNTIME_MONITORING disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_runtime_monitoring_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "NONE"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 9: FAIL - Organization RUNTIME_MONITORING enabled but EC2_AGENT_MANAGEMENT disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_ec2_agent_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        auto_enable = "NONE"
      }
    ]
  }
}

# Test 10: FAIL - Organization RUNTIME_MONITORING enabled but no additional_configuration
resource "aws_guardduty_organization_configuration_feature" "fail_org_no_additional_config" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
  }
}

# Test 11: FAIL - Organization RUNTIME_MONITORING enabled with empty additional_configuration
resource "aws_guardduty_organization_configuration_feature" "fail_org_empty_additional_config" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = []
  }
}
