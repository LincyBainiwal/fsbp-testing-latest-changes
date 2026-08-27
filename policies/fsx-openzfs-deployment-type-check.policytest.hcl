# Copyright IBM Corp. 2026

policytest {
    targets = [
        "fsx-openzfs-deployment-type-check.policy.hcl"
    ]
}

# Test 1: PASS - File system with MULTI_AZ_1 deployment type
resource "aws_fsx_openzfs_file_system" "pass_multi_az_1" {
  attrs = {
    deployment_type = "MULTI_AZ_1"
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
    throughput_capacity = 160
    preferred_subnet_id = "subnet-12345678"
    storage_capacity = 64
  }
}

# Test 2: FAIL - File system with SINGLE_AZ_1 deployment type
resource "aws_fsx_openzfs_file_system" "fail_single_az_1" {
  expect_failure = true
  attrs = {
    deployment_type = "SINGLE_AZ_1"
    subnet_ids = ["subnet-12345678"]
    throughput_capacity = 64
    storage_capacity = 64
  }
}

# Test 3: FAIL - File system with SINGLE_AZ_2 deployment type
resource "aws_fsx_openzfs_file_system" "fail_single_az_2" {
  expect_failure = true
  attrs = {
    deployment_type = "SINGLE_AZ_2"
    subnet_ids = ["subnet-12345678"]
    throughput_capacity = 64
    storage_capacity = 64
  }
}
