# Copyright IBM Corp. 2026

policytest {
    targets = [
        "neptune-cluster-deletion-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Deletion protection enabled (true)
resource "aws_neptune_cluster" "pass_deletion_protection_enabled" {
  attrs = {
    cluster_identifier      = "neptune-protected"
    deletion_protection     = true
    engine                  = "neptune"
  }
}

# Test 2: FAIL - Deletion protection disabled (false)
resource "aws_neptune_cluster" "fail_deletion_protection_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "neptune-not-protected"
    deletion_protection     = false
    engine                  = "neptune"
  }
}

# Test 3: FAIL - Missing deletion_protection (defaults to false)
resource "aws_neptune_cluster" "fail_missing_deletion_protection" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "neptune-missing-protection"
    engine                  = "neptune"
  }
}
