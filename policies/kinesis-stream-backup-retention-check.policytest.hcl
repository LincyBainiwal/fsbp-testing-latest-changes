# Copyright IBM Corp. 2026

policytest {
  targets = [
    "kinesis-stream-backup-retention-check.policy.hcl"
  ]
}
# Pass case: Retention period exactly at minimum (168 hours)
resource "aws_kinesis_stream" "compliant_minimum" {
  attrs = {
    name = "compliant-stream-minimum"
    retention_period = 168
    shard_count = 1
  }
}

# Pass case: Retention period well above minimum (336 hours)
resource "aws_kinesis_stream" "compliant_high" {
  attrs = {
    name = "compliant-stream-high"
    retention_period = 336
    shard_count = 1
  }
}

# Pass case: Retention period at maximum allowed (8760 hours)
resource "aws_kinesis_stream" "compliant_maximum" {
  attrs = {
    name = "compliant-stream-maximum"
    retention_period = 8760
    shard_count = 1
  }
}

# Fail case: Retention period at provider default (24 hours)
resource "aws_kinesis_stream" "noncompliant_default" {
  expect_failure = true
  attrs = {
    name = "noncompliant-stream-default"
    retention_period = 24
    shard_count = 1
  }
}

# Fail case: Retention period above default but below minimum (100 hours)
resource "aws_kinesis_stream" "noncompliant_low" {
  expect_failure = true
  attrs = {
    name = "noncompliant-stream-low"
    retention_period = 100
    shard_count = 1
  }
}

# Fail case: Retention period just below minimum (167 hours)
resource "aws_kinesis_stream" "noncompliant_edge" {
  expect_failure = true
  attrs = {
    name = "noncompliant-stream-edge"
    retention_period = 167
    shard_count = 1
  }
}
