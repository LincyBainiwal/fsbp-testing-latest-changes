# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-runtime-monitoring-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Runtime Monitoring enabled with EC2 agent management
resource "aws_guardduty_detector_feature" "pass_runtime_ec2" {
  attrs = {
    detector_id = "detector-12345"
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

# Test 2: PASS - Runtime Monitoring enabled with ECS Fargate agent management
resource "aws_guardduty_detector_feature" "pass_runtime_ecs" {
  attrs = {
    detector_id = "detector-23456"
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

# Test 3: PASS - Runtime Monitoring enabled with EKS addon management
resource "aws_guardduty_detector_feature" "pass_runtime_eks" {
  attrs = {
    detector_id = "detector-34567"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 4: PASS - Runtime Monitoring enabled with multiple agent types
resource "aws_guardduty_detector_feature" "pass_runtime_multiple" {
  attrs = {
    detector_id = "detector-45678"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        status = "ENABLED"
      },
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        status = "ENABLED"
      },
      {
        name = "EKS_ADDON_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 5: FAIL - Runtime Monitoring feature disabled
resource "aws_guardduty_detector_feature" "fail_runtime_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "detector-67890"
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

# Test 6: FAIL - Runtime Monitoring enabled but no additional configuration
resource "aws_guardduty_detector_feature" "fail_runtime_no_config" {
  expect_failure = true
  attrs = {
    detector_id = "detector-78901"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = []
  }
}

# Test 7: FAIL - Runtime Monitoring enabled but all agents disabled
resource "aws_guardduty_detector_feature" "fail_runtime_all_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "detector-89012"
    name = "RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EC2_AGENT_MANAGEMENT"
        status = "DISABLED"
      },
      {
        name = "ECS_FARGATE_AGENT_MANAGEMENT"
        status = "DISABLED"
      },
      {
        name = "EKS_ADDON_MANAGEMENT"
        status = "DISABLED"
      }
    ]
  }
}

# Test 8: PASS - Runtime Monitoring fully enabled with addon management
resource "aws_guardduty_organization_configuration_feature" "pass_org_runtime" {
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 9: FAIL - Runtime Monitoring with status DISABLED
resource "aws_guardduty_organization_configuration_feature" "fail_org_runtime" {
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

# Test 10: FAIL - Runtime Monitoring enabled but addon management disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_runtime_addon_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        auto_enable = "NONE"
      }
    ]
  }
}

# Test 11: FAIL - Runtime Monitoring enabled but no additional_configuration
resource "aws_guardduty_organization_configuration_feature" "fail_org_runtime_no_addon" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "RUNTIME_MONITORING"
    auto_enable = "ALL"
  }
}

# Test 12: SKIP - Different feature type (S3_DATA_EVENTS) should be filtered out
resource "aws_guardduty_detector_feature" "pass_different_feature_filtered" {
  attrs = {
    detector_id = "abc123"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
  }
}
