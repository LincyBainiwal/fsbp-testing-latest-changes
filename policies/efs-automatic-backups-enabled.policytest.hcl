# Copyright IBM Corp. 2026

policytest {
    targets = [
        "efs-automatic-backups-enabled.policy.hcl"
    ]
}

# ---------------------------------------------------------------------------
# PASS cases
# ---------------------------------------------------------------------------

# Test 1: PASS - File system with an associated backup policy status = ENABLED
resource "aws_efs_backup_policy" "pass_enabled_pol" {
  attrs = {
    file_system_id = "fs-aabbccdd"
    backup_policy = [
      {
        status = "ENABLED"
      }
    ]
  }
}

resource "aws_efs_file_system" "pass_enabled" {
  attrs = {
    id = "fs-aabbccdd"
  }
}

# ---------------------------------------------------------------------------
# FAIL cases
# ---------------------------------------------------------------------------

# Test 2: FAIL - File system has NO associated aws_efs_backup_policy at all.
resource "aws_efs_file_system" "fail_no_backup_policy" {
  expect_failure = true
  attrs = {
    id = "fs-no-backup"
  }
}

# Test 3: FAIL - Associated backup policy exists but status = DISABLED
resource "aws_efs_backup_policy" "fail_disabled_pol" {
  attrs = {
    file_system_id = "fs-disabled"
    backup_policy = [
      {
        status = "DISABLED"
      }
    ]
  }
}

resource "aws_efs_file_system" "fail_disabled" {
  expect_failure = true
  attrs = {
    id = "fs-disabled"
  }
}

# Test 4: FAIL - Associated backup policy has an empty backup_policy block
# (no status field — defaults to DISABLED)
resource "aws_efs_backup_policy" "fail_missing_status_pol" {
  attrs = {
    file_system_id = "fs-missing-status"
    backup_policy = [
      {
        # status field omitted — core::try returns "DISABLED"
      }
    ]
  }
}

resource "aws_efs_file_system" "fail_missing_status" {
  expect_failure = true
  attrs = {
    id = "fs-missing-status"
  }
}

# Test 5: FAIL - Associated backup policy has an empty list for backup_policy
resource "aws_efs_backup_policy" "fail_empty_list_pol" {
  attrs = {
    file_system_id = "fs-empty-list"
    backup_policy  = []
  }
}

resource "aws_efs_file_system" "fail_empty_list" {
  expect_failure = true
  attrs = {
    id = "fs-empty-list"
  }
}