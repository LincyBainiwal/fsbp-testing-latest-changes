# Copyright IBM Corp. 2026

policytest {
    targets = [
        "fsx-openzfs-copy-tags-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Copy tags to backups and volumes is enabled
resource "aws_fsx_openzfs_file_system" "pass_copy_tags_enabled" {
    attrs = {
        storage_capacity    = 64
        subnet_ids          = "test_subnet_id"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 64
        copy_tags_to_backups = true
        copy_tags_to_volumes = true
    }
}

# Test 2: FAIL - Copy tags to backups is disabled
resource "aws_fsx_openzfs_file_system" "fail_copy_tags_backup_disabled" {
    expect_failure = true
    attrs = {
        storage_capacity    = 64
        subnet_ids          = "test_subnet_id"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 64
        copy_tags_to_backups = false
        copy_tags_to_volumes = true
    }
}

# Test 3: FAIL - Copy tags to volumes is disabled
resource "aws_fsx_openzfs_file_system" "fail_copy_tags_volume_disabled" {
    expect_failure = true
    attrs = {
        storage_capacity    = 64
        subnet_ids          = "test_subnet_id"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 64
        copy_tags_to_backups = true
        copy_tags_to_volumes = false
    }
}

# Test 4: FAIL - Both copy tags to backups and volumes are disabled
resource "aws_fsx_openzfs_file_system" "fail_copy_tags_disabled" {
    expect_failure = true
    attrs = {
        storage_capacity    = 64
        subnet_ids          = "test_subnet_id"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 64
        copy_tags_to_backups = false
        copy_tags_to_volumes = false
    }
}

# Test 5: FAIL - Copy tags to backups is missing
resource "aws_fsx_openzfs_file_system" "fail_copy_tags_backup_missing" {
    expect_failure = true
    attrs = {
        storage_capacity    = 64
        subnet_ids          = "test_subnet_id"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 64
        copy_tags_to_volumes = true
    }
}

# Test 6: FAIL - Both copy tags to backups and volumes are missing
resource "aws_fsx_openzfs_file_system" "fail_copy_tags_missing" {
    expect_failure = true
    attrs = {
        storage_capacity    = 64
        subnet_ids          = "test_subnet_id"
        deployment_type     = "SINGLE_AZ_1"
        throughput_capacity = 64
    }
}
