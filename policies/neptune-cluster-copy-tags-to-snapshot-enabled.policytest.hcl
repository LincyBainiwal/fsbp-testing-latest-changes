# Copyright IBM Corp. 2026

policytest {
    targets = [
        "neptune-cluster-copy-tags-to-snapshot-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Copy tags to snapshot is enabled
resource "aws_neptune_cluster" "pass_copy_tags_enabled" {
    attrs = {
        copy_tags_to_snapshot = true
        engine = "neptune"
    }
}

# Test 2: FAIL - Copy tags to snapshot is disabled
resource "aws_neptune_cluster" "fail_copy_tags_disabled" {
    expect_failure = true
    attrs = {
        copy_tags_to_snapshot = false
        engine = "neptune"
    }
}

# Test 3: FAIL - Missing copy_tags_to_snapshot (defaults to false)
resource "aws_neptune_cluster" "fail_copy_tags_missing" {
    expect_failure = true
    attrs = {
        engine = "neptune"
    }
}
