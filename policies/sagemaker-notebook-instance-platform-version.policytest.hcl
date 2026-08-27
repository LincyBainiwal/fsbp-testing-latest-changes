# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-notebook-instance-platform-version.policy.hcl"
    ]
}

# Test 1: PASS - Explicit supported platform
resource "aws_sagemaker_notebook_instance" "pass_explicit_supported_platform" {
  attrs = {
    name                = "compliant-notebook"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    platform_identifier = "notebook-al2-v3"
  }
}

# Test 2: PASS - Default platform (not explicitly set)
resource "aws_sagemaker_notebook_instance" "pass_default_platform" {
  attrs = {
    name          = "default-notebook"
    role_arn      = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type = "ml.t3.medium"
  }
}

# Test 3: FAIL - Deprecated platform notebook-al1-v1
resource "aws_sagemaker_notebook_instance" "fail_deprecated_al1_v1" {
  expect_failure = true
  attrs = {
    name                = "deprecated-notebook-al1"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    platform_identifier = "notebook-al1-v1"
  }
}

# Test 4: FAIL - Deprecated platform notebook-al2-v1
resource "aws_sagemaker_notebook_instance" "fail_deprecated_al2_v1" {
  expect_failure = true
  attrs = {
    name                = "deprecated-notebook-al2-v1"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    platform_identifier = "notebook-al2-v1"
  }
}

# Test 5: FAIL - Deprecated platform notebook-al2-v2
resource "aws_sagemaker_notebook_instance" "fail_deprecated_al2_v2" {
  expect_failure = true
  attrs = {
    name                = "deprecated-notebook-al2-v2"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    platform_identifier = "notebook-al2-v2"
  }
}