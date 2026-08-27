# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-notebook-instance-root-access-check.policy.hcl"
    ]
}

# Test 1: PASS - Root access explicitly disabled
resource "aws_sagemaker_notebook_instance" "pass_root_access_disabled" {
  attrs = {
    name                = "compliant-notebook"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    root_access         = "Disabled"
    platform_identifier = "notebook-al2-v2"
  }
}

# Test 2: FAIL - Root access explicitly enabled
resource "aws_sagemaker_notebook_instance" "fail_root_access_enabled" {
  expect_failure = true
  attrs = {
    name                = "non-compliant-notebook"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    root_access         = "Enabled"
    platform_identifier = "notebook-al2-v2"
  }
}

# Test 3: FAIL - Root access not specified (defaults to Enabled)
resource "aws_sagemaker_notebook_instance" "fail_root_access_not_specified" {
  expect_failure = true
  attrs = {
    name                = "default-notebook"
    role_arn            = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type       = "ml.t3.medium"
    platform_identifier = "notebook-al2-v2"
  }
}
