# Copyright IBM Corp. 2026

policytest {
    targets = [
        "fsx-windows-deployment-type-check.policy.hcl"
    ]
}

# Test 1: PASS - Windows file system with MULTI_AZ_1 deployment type
resource "aws_fsx_windows_file_system" "pass_multi_az_1" {
  attrs = {
    deployment_type = "MULTI_AZ_1"
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
    throughput_capacity = 32
    storage_capacity = 32
  }
}

# Test 2: FAIL - Windows file system with SINGLE_AZ_1 deployment type
resource "aws_fsx_windows_file_system" "fail_single_az_1" {
  expect_failure = true
  attrs = {
    deployment_type = "SINGLE_AZ_1"
    subnet_ids = ["subnet-12345678"]
    throughput_capacity = 32
    storage_capacity = 32
  }
}

# Test 3: FAIL - Windows file system with SINGLE_AZ_2 deployment type
resource "aws_fsx_windows_file_system" "fail_single_az_2" {
  expect_failure = true
  attrs = {
    deployment_type = "SINGLE_AZ_2"
    subnet_ids = ["subnet-12345678"]
    throughput_capacity = 32
    storage_capacity = 32
  }
}

# Test 4: FAIL - Windows file system with missing deployment type
resource "aws_fsx_windows_file_system" "fail_missing_deployment_type" {
  expect_failure = true
  attrs = {
    subnet_ids = ["subnet-12345678"]
    throughput_capacity = 32
    storage_capacity = 32
  }
}
