# Copyright IBM Corp. 2026

policytest {
  targets = ["sqs-queue-encrypted.policy.hcl"]
}

# Pass Case 1: SQS queue with SSE-SQS encryption enabled
resource "aws_sqs_queue" "pass_sqs_managed_sse" {
  attrs = {
    name                       = "encrypted-queue-sqs"
    sqs_managed_sse_enabled    = true
  }
}

# Pass Case 2: SQS queue with SSE-KMS encryption using KMS key ID
resource "aws_sqs_queue" "pass_kms_key_id" {
  attrs = {
    name                       = "encrypted-queue-kms"
    kms_master_key_id          = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

# Pass Case 3: SQS queue with SSE-KMS encryption using KMS key alias
resource "aws_sqs_queue" "pass_kms_alias" {
  attrs = {
    name                       = "encrypted-queue-alias"
    kms_master_key_id          = "alias/aws/sqs"
  }
}

# Pass Case 4: SQS queue with both SSE-SQS and SSE-KMS configured
resource "aws_sqs_queue" "pass_both_encryption_methods" {
  attrs = {
    name                       = "encrypted-queue-both"
    sqs_managed_sse_enabled    = true
    kms_master_key_id          = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

# Fail Case 1: SQS queue without any encryption
resource "aws_sqs_queue" "fail_no_encryption" {
  expect_failure = true
  attrs = {
    name = "unencrypted-queue"
  }
}

# Fail Case 2: SQS queue with sqs_managed_sse_enabled explicitly set to false
resource "aws_sqs_queue" "fail_sse_disabled" {
  expect_failure = true
  attrs = {
    name                       = "sse-disabled-queue"
    sqs_managed_sse_enabled    = false
  }
}

# Fail Case 3: SQS queue with empty kms_master_key_id
resource "aws_sqs_queue" "fail_empty_kms_key" {
  expect_failure = true
  attrs = {
    name                       = "empty-kms-queue"
    kms_master_key_id          = ""
  }
}
