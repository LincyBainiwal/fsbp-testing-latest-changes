# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-imdsv2-check.policy.hcl"
  ]
}

# --------------- aws_instance tests ---------------

# Test 1: PASS - Instance explicitly sets http_tokens = "required"
resource "aws_instance" "pass_instance_imdsv2_required" {
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = [
      {
        http_tokens = "required"
      }
    ]
  }
}

# Test 2: FAIL - Instance sets http_tokens = "optional"
resource "aws_instance" "fail_instance_imdsv2_optional" {
  expect_failure = true
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = [
      {
        http_tokens = "optional"
      }
    ]
  }
}

# Test 3: FAIL - Instance has no metadata_options block (defaults to "optional")
resource "aws_instance" "fail_instance_no_metadata_options" {
  expect_failure = true
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
  }
}

# Test 4: FAIL - Instance sets http_tokens = "no-preference" (does not guarantee IMDSv2)
resource "aws_instance" "fail_instance_no_preference" {
  expect_failure = true
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = [
      {
        http_tokens = "no-preference"
      }
    ]
  }
}

# --------------- aws_launch_template tests ---------------

# Test 5: PASS - Launch template explicitly sets http_tokens = "required"
resource "aws_launch_template" "pass_lt_imdsv2_required" {
  attrs = {
    name = "compliant-lt"
    metadata_options = [
      {
        http_tokens = "required"
      }
    ]
  }
}

# Test 6: FAIL - Launch template sets http_tokens = "optional"
resource "aws_launch_template" "fail_lt_imdsv2_optional" {
  expect_failure = true
  attrs = {
    name = "non-compliant-lt-optional"
    metadata_options = [
      {
        http_tokens = "optional"
      }
    ]
  }
}

# Test 7: FAIL - Launch template has no metadata_options (defaults to "optional")
resource "aws_launch_template" "fail_lt_no_metadata_options" {
  expect_failure = true
  attrs = {
    name = "non-compliant-lt-no-metadata"
  }
}