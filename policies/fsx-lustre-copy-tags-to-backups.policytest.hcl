# Copyright IBM Corp. 2026

policytest {
    targets = [
        "fsx-lustre-copy-tags-to-backups.policy.hcl"
    ]
}


# Test 1: PASS - Copy tags to backups is enabled
resource "aws_fsx_lustre_file_system" "pass_copy_tags_enabled" {
    attrs = {
        storage_capacity = 1200
        subnet_ids       = "test_subnet_id"
        deployment_type     = "PERSISTENT_1"
        copy_tags_to_backups = true
    }
}

# Test 2: FAIL - Copy tags to backups is disabled
resource "aws_fsx_lustre_file_system" "fail_copy_tags_disabled" {
    expect_failure = true
    attrs = {
        storage_capacity = 1200
        subnet_ids       = "test_subnet_id"
        deployment_type     = "PERSISTENT_1"
        copy_tags_to_backups = false
    }
}

# Test 3: SKIP - Deployment type is SCRATCH_2 (should be PERSISTENT_1 or PERSISTENT_2)
resource "aws_fsx_lustre_file_system" "fail_wrong_deployment" {
    attrs = {
        storage_capacity = 1200
        subnet_ids       = "test_subnet_id"
        deployment_type     = "SCRATCH_2"
        copy_tags_to_backups = true
    }
}

# Test 4: PASS - Deployment type is PERSISTENT_2 and copy tags is enabled
resource "aws_fsx_lustre_file_system" "pass_persistent_2" {
    attrs = {
        storage_capacity = 1200
        subnet_ids       = "test_subnet_id"
        deployment_type     = "PERSISTENT_2"
        copy_tags_to_backups = true
    }
}

# Test 5: FAIL - Deployment type is PERSISTENT_2 but copy tags is missing
resource "aws_fsx_lustre_file_system" "fail_persistent_2" {
    expect_failure = true
    attrs = {
        storage_capacity = 1200
        subnet_ids       = "test_subnet_id"
        deployment_type     = "PERSISTENT_2"
    }
}
