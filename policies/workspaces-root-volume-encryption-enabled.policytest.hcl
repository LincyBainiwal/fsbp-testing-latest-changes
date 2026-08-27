# Copyright IBM Corp. 2026

policytest {
    targets = [
        "workspaces-root-volume-encryption-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Root volume encryption is enabled
resource "aws_workspaces_workspace" "pass_root_volume_encrypted" {
  attrs = {
    workspace_id                    = "ws-root-encrypted"
    root_volume_encryption_enabled  = true
  }
}

# Test 2: FAIL - Root volume encryption is disabled
resource "aws_workspaces_workspace" "fail_root_volume_not_encrypted" {
  expect_failure = true
  attrs = {
    workspace_id                    = "ws-root-unencrypted"
    root_volume_encryption_enabled  = false
  }
}

# Test 3: FAIL - Missing root_volume_encryption_enabled defaults to false
resource "aws_workspaces_workspace" "fail_root_volume_missing_encryption" {
  expect_failure = true
  attrs = {
    workspace_id = "ws-root-missing-encryption"
  }
}

