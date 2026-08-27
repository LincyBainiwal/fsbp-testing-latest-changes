# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-model-isolation-enabled.policy.hcl"
    ]
}

# Test 1: PASS - SageMaker model with network isolation enabled
resource "aws_sagemaker_model" "pass_with_isolation_enabled" {
  attrs = {
    name                      = "compliant-model"
    execution_role_arn        = "arn:aws:iam::123456789012:role/SageMakerRole"
    enable_network_isolation  = true
    primary_container = [{
      image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-model:latest"
    }]
  }
}

# Test 2: FAIL - SageMaker model with network isolation explicitly disabled
resource "aws_sagemaker_model" "fail_with_isolation_disabled" {
  expect_failure = true
  attrs = {
    name                      = "non-compliant-model"
    execution_role_arn        = "arn:aws:iam::123456789012:role/SageMakerRole"
    enable_network_isolation  = false
    primary_container = [{
      image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-model:latest"
    }]
  }
}

# Test 3: FAIL - SageMaker model without network isolation specified (defaults to false)
resource "aws_sagemaker_model" "fail_without_isolation_specified" {
  expect_failure = true
  attrs = {
    name                      = "default-model"
    execution_role_arn        = "arn:aws:iam::123456789012:role/SageMakerRole"
    primary_container = [{
      image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-model:latest"
    }]
  }
}
