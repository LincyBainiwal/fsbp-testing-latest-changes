# Copyright IBM Corp. 2026

policytest {
  targets = [
    "kinesis-stream-encrypted.policy.hcl"
  ]
}

resource "aws_kinesis_stream" "pass_kms_with_key_id" {
  attrs = {
    name = "compliant-stream"
    encryption_type = "KMS"
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    shard_count = 1
  }
}

resource "aws_kinesis_stream" "pass_kms_with_aws_managed_key" {
  attrs = {
    name = "aws-managed-stream"
    encryption_type = "KMS"
    kms_key_id = "alias/aws/kinesis"
    shard_count = 1
  }
}

resource "aws_kinesis_stream" "fail_encryption_none" {
  expect_failure = true
  attrs = {
    name = "unencrypted-stream"
    encryption_type = "NONE"
    shard_count = 1
  }
}

resource "aws_kinesis_stream" "fail_no_encryption_type" {
  expect_failure = true
  attrs = {
    name = "default-unencrypted-stream"
    shard_count = 1
  }
}

resource "aws_kinesis_stream" "fail_kms_without_key_id" {
  expect_failure = true
  attrs = {
    name = "missing-key-stream"
    encryption_type = "KMS"
    shard_count = 1
  }
}

resource "aws_kinesis_stream" "fail_kms_with_empty_key_id" {
  expect_failure = true
  attrs = {
    name = "empty-key-stream"
    encryption_type = "KMS"
    kms_key_id = ""
    shard_count = 1
  }
}