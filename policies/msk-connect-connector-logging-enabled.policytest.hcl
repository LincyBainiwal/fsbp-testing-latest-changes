# Copyright IBM Corp. 2026

policytest {
  targets = [
    "msk-connect-connector-logging-enabled.policy.hcl"
  ]
}
# PASS: CloudWatch Logs enabled with log_group
resource "aws_mskconnect_connector" "pass_cloudwatch_logs" {
  attrs = {
    name = "test-connector-cloudwatch"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = true
                log_group = "/aws/msk/connector/test"
              }
            ]
            firehose = [
              {
                enabled = false
              }
            ]
            s3 = [
              {
                enabled = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# PASS: Firehose enabled with delivery_stream
resource "aws_mskconnect_connector" "pass_firehose" {
  attrs = {
    name = "test-connector-firehose"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = false
              }
            ]
            firehose = [
              {
                enabled = true
                delivery_stream = "test-delivery-stream"
              }
            ]
            s3 = [
              {
                enabled = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# PASS: S3 enabled with bucket
resource "aws_mskconnect_connector" "pass_s3" {
  attrs = {
    name = "test-connector-s3"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = false
              }
            ]
            firehose = [
              {
                enabled = false
              }
            ]
            s3 = [
              {
                enabled = true
                bucket = "test-msk-logs-bucket"
                prefix = "connector-logs/"
              }
            ]
          }
        ]
      }
    ]
  }
}

# PASS: All three logging destinations enabled
resource "aws_mskconnect_connector" "pass_all_destinations" {
  attrs = {
    name = "test-connector-all"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = true
                log_group = "/aws/msk/connector/test"
              }
            ]
            firehose = [
              {
                enabled = true
                delivery_stream = "test-delivery-stream"
              }
            ]
            s3 = [
              {
                enabled = true
                bucket = "test-msk-logs-bucket"
              }
            ]
          }
        ]
      }
    ]
  }
}

# FAIL: One valid destination does not offset another enabled but invalid destination
resource "aws_mskconnect_connector" "fail_mixed_valid_and_invalid_destinations" {
  expect_failure = true
  attrs = {
    name = "test-connector-mixed-invalid"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = true
                log_group = "/aws/msk/connector/test"
              }
            ]
            firehose = [
              {
                enabled = false
              }
            ]
            s3 = [
              {
                enabled = true
                # Missing bucket
              }
            ]
          }
        ]
      }
    ]
  }
}

# FAIL: No logging destinations enabled
resource "aws_mskconnect_connector" "fail_no_logging" {
  expect_failure = true
  attrs = {
    name = "test-connector-no-logging"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = false
              }
            ]
            firehose = [
              {
                enabled = false
              }
            ]
            s3 = [
              {
                enabled = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# FAIL: CloudWatch enabled but missing log_group
resource "aws_mskconnect_connector" "fail_cloudwatch_missing_log_group" {
  expect_failure = true
  attrs = {
    name = "test-connector-cloudwatch-invalid"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = true
                # Missing log_group
              }
            ]
            firehose = [
              {
                enabled = false
              }
            ]
            s3 = [
              {
                enabled = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# FAIL: Firehose enabled but missing delivery_stream
resource "aws_mskconnect_connector" "fail_firehose_missing_delivery_stream" {
  expect_failure = true
  attrs = {
    name = "test-connector-firehose-invalid"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = false
              }
            ]
            firehose = [
              {
                enabled = true
                # Missing delivery_stream
              }
            ]
            s3 = [
              {
                enabled = false
              }
            ]
          }
        ]
      }
    ]
  }
}

# FAIL: S3 enabled but missing bucket
resource "aws_mskconnect_connector" "fail_s3_missing_bucket" {
  expect_failure = true
  attrs = {
    name = "test-connector-s3-invalid"
    log_delivery = [
      {
        worker_log_delivery = [
          {
            cloudwatch_logs = [
              {
                enabled = false
              }
            ]
            firehose = [
              {
                enabled = false
              }
            ]
            s3 = [
              {
                enabled = true
                # Missing bucket
              }
            ]
          }
        ]
      }
    ]
  }
}

# Filtered out: No log_delivery block
resource "aws_mskconnect_connector" "filtered_no_log_delivery" {
  attrs = {
    name = "test-connector-no-log-delivery"
    # No log_delivery block - should be filtered by policy
  }
}