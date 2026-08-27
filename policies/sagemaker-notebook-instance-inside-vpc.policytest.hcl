# Copyright IBM Corp. 2026

policytest {
    targets = [
        "sagemaker-notebook-instance-inside-vpc.policy.hcl"
    ]
}

# Test 1: PASS - Notebook instance with subnet_id configured
resource "aws_sagemaker_notebook_instance" "pass_with_subnet_id" {
  attrs = {
    name = "compliant-notebook"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type = "ml.t3.medium"
    subnet_id = "subnet-12345678"
    security_groups = ["sg-12345678"]
  }
}

# Test 2: FAIL - Notebook instance without subnet_id
resource "aws_sagemaker_notebook_instance" "fail_without_subnet_id" {
  expect_failure = true
  attrs = {
    name = "non-compliant-notebook"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type = "ml.t3.medium"
  }
}

# Test 3: FAIL - Notebook instance with empty string subnet_id
resource "aws_sagemaker_notebook_instance" "fail_with_empty_subnet_id" {
  expect_failure = true
  attrs = {
    name = "empty-subnet-notebook"
    role_arn = "arn:aws:iam::123456789012:role/SageMakerRole"
    instance_type = "ml.t3.medium"
    subnet_id = ""
  }
}
