# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-ecs-protection-runtime-enabled.policy.hcl"
    ]
}

# Test 1: PASS - RUNTIME_MONITORING enabled with ECS_FARGATE_AGENT_MANAGEMENT enabled
resource "aws_guardduty_detector_feature" "pass_runtime_monitoring_with_ecs_fargate_enabled" {
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 2: FAIL - RUNTIME_MONITORING enabled but ECS_FARGATE_AGENT_MANAGEMENT disabled
resource "aws_guardduty_detector_feature" "fail_ecs_fargate_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        status = "DISABLED"
      }
    ]
  }
}

# Test 3: FAIL - RUNTIME_MONITORING disabled
resource "aws_guardduty_detector_feature" "fail_runtime_monitoring_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    status = "DISABLED"
    additional_configuration = [
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 4: FAIL - RUNTIME_MONITORING enabled but no additional_configuration
resource "aws_guardduty_detector_feature" "fail_no_additional_configuration" {
  expect_failure = true
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = []
  }
}

# Test 5: SKIP - Different feature name (not RUNTIME_MONITORING) - should pass due to filter
resource "aws_guardduty_detector_feature" "skip_different_feature" {
  attrs = {
    detector_id = "detector-123"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
    additional_configuration = []
  }
}

# Test 6: PASS - Organization RUNTIME_MONITORING enabled with ECS_FARGATE_AGENT_MANAGEMENT enabled
resource "aws_guardduty_organization_configuration_feature" "pass_org_runtime_monitoring_with_ecs_fargate_enabled" {
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 7: FAIL - Organization RUNTIME_MONITORING enabled but ECS_FARGATE_AGENT_MANAGEMENT disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_ecs_fargate_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        auto_enable = "NONE"
      }
    ]
  }
}

# Test 8: FAIL - Organization RUNTIME_MONITORING disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_runtime_monitoring_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    auto_enable = "NONE"
    additional_configuration = [
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 9: FAIL - Organization RUNTIME_MONITORING enabled but no additional_configuration
resource "aws_guardduty_organization_configuration_feature" "fail_org_no_additional_configuration" {
  expect_failure = true
  attrs = {
    detector_id = "detector-123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = []
  }
}
