# Copyright IBM Corp. 2026

policytest {
    targets = [
        "efs-in-backup-plan.policy.hcl"
    ]
}

# Test 1: PASS - EFS file system explicitly referenced in backup selection
resource "aws_efs_file_system" "protected" {
  attrs = {
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678"
    encrypted = true
    tags = {
      Name = "protected-efs"
      Environment = "production"
    }
  }
}

resource "aws_backup_selection" "efs_selection" {
  skip = true
  attrs = {
    name = "efs-backup-selection"
    plan_id = "backup-plan-123"
    iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupRole"
    resources = [
      "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678"
    ]
  }
}

# Test 2: Fail - EFS file system with missing backup selection resource
resource "aws_efs_file_system" "missing-backup-plan" {
  attrs = {
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-87654321"
    encrypted = true
    tags = {
      Name = "tagged-efs"
      Environment = "production"
    }
  }
  expect_failure = true
}

# Test 3: FAIL - EFS file system not in any backup plan
resource "aws_efs_file_system" "unprotected" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-99999999"
    encrypted = true
    tags = {
      Name = "unprotected-efs"
      Environment = "development"
    }
  }
}

resource "aws_backup_selection" "other_selection" {
  skip = true
  attrs = {
    name = "other-backup-selection"
    plan_id = "backup-plan-789"
    iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupRole"
    resources = [
      "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-11111111"
    ]
  }
}
