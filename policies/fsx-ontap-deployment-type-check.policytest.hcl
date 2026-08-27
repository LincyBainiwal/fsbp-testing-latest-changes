# Copyright IBM Corp. 2026

policytest {
    targets = [
        "fsx-ontap-deployment-type-check.policy.hcl"
    ]
}

# Test 1: PASS - Multi-AZ-1 deployment type is set
resource "aws_fsx_ontap_file_system" "pass_multi_az_1" {
    attrs = {
        storage_capacity    = 1024
        subnet_ids          = "test_subnet_1"
        deployment_type     = "MULTI_AZ_1"
        throughput_capacity = 512
        preferred_subnet_id = "test_subnet_1"
    }
}

# Test 2: PASS - Multi-AZ-2 deployment type is set
resource "aws_fsx_ontap_file_system" "pass_multi_az_2" {
    attrs = {
        storage_capacity    = 1024
        subnet_ids          = "test_subnet_1"
        deployment_type     = "MULTI_AZ_2"
        throughput_capacity = 512
        preferred_subnet_id = "test_subnet_1"
    }
}

# Test 3: FAIL - Single-AZ deployment type is set
resource "aws_fsx_ontap_file_system" "fail_single_az" {
    expect_failure = true
    attrs = {
        storage_capacity    = 1024
        subnet_ids          = "test_subnet_1"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 512
        preferred_subnet_id = "test_subnet_1"
    }
}
