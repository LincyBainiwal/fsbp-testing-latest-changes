# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-notebook-no-direct-internet-access.policy.hcl"
    ]
}

# Test 1: PASS - Notebook instance with direct_internet_access disabled and complete VPC configuration
resource "aws_sagemaker_notebook_instance" "compliant" {
  attrs = {
    name                   = "compliant-notebook"
    role_arn              = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type         = "ml.t3.medium"
    direct_internet_access = "Disabled"
    subnet_id             = "subnet-12345678"
    security_groups       = ["sg-12345678", "sg-87654321"]
  }
}

# Test 2: FAIL - Notebook instance with direct_internet_access explicitly enabled
resource "aws_sagemaker_notebook_instance" "non_compliant_enabled" {
  expect_failure = true
  attrs = {
    name                   = "non-compliant-notebook"
    role_arn              = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type         = "ml.t3.medium"
    direct_internet_access = "Enabled"
  }
}

# Test 3: FAIL - Notebook instance without direct_internet_access specified (defaults to Enabled)
resource "aws_sagemaker_notebook_instance" "non_compliant_default" {
  expect_failure = true
  attrs = {
    name          = "default-notebook"
    role_arn      = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type = "ml.t3.medium"
  }
}

# Test 4: FAIL - Notebook instance with direct_internet_access disabled but missing subnet_id
resource "aws_sagemaker_notebook_instance" "missing_subnet" {
  expect_failure = true
  attrs = {
    name                   = "incomplete-vpc-notebook"
    role_arn              = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type         = "ml.t3.medium"
    direct_internet_access = "Disabled"
    security_groups       = ["sg-12345678"]
  }
}

# Test 5: FAIL - Notebook instance with direct_internet_access disabled but missing security_groups
resource "aws_sagemaker_notebook_instance" "missing_sg" {
  expect_failure = true
  attrs = {
    name                   = "incomplete-sg-notebook"
    role_arn              = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type         = "ml.t3.medium"
    direct_internet_access = "Disabled"
    subnet_id             = "subnet-12345678"
  }
}

# Test 6: FAIL - Notebook instance with direct_internet_access disabled but empty security_groups list
resource "aws_sagemaker_notebook_instance" "empty_sg" {
  expect_failure = true
  attrs = {
    name                   = "empty-sg-notebook"
    role_arn              = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type         = "ml.t3.medium"
    direct_internet_access = "Disabled"
    subnet_id             = "subnet-12345678"
    security_groups       = []
  }
}
