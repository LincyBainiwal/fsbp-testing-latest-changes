# Copyright IBM Corp. 2026

policytest {
    targets = [
        "workspaces-user-volume-encryption-enabled.policy.hcl"
    ]
}

# Test 1: PASS - User volume encryption is enabled
resource "aws_workspaces_workspace" "pass_user_volume_encrypted" {
  attrs = {
    workspace_id                    = "ws-user-encrypted"
    user_volume_encryption_enabled  = true
  }
}

# Test 2: FAIL - User volume encryption is disabled
resource "aws_workspaces_workspace" "fail_user_volume_not_encrypted" {
  expect_failure = true
  attrs = {
    workspace_id                    = "ws-user-unencrypted"
    user_volume_encryption_enabled  = false
  }
}

# Test 3: FAIL - Missing user_volume_encryption_enabled defaults to false
resource "aws_workspaces_workspace" "fail_user_volume_missing_encryption" {
  expect_failure = true
  attrs = {
    workspace_id = "ws-user-missing-encryption"
  }
}
