# Copyright IBM Corp. 2026

policytest {
  targets = [
            "network-firewall-logging-enabled.policy.hcl"
  ]
}
# Pass Case 1: ALERT logging to CloudWatch
resource "aws_networkfirewall_logging_configuration" "pass_alert_cloudwatch" {
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = [
          {
            log_destination = {
              logGroup = "/aws/networkfirewall/test"
            }
            log_destination_type = "CloudWatchLogs"
            log_type = "ALERT"
          }
        ]
      }
    ]
  }
}

# Pass Case 2: FLOW logging to S3
resource "aws_networkfirewall_logging_configuration" "pass_flow_s3" {
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = [
          {
            log_destination = {
              bucketName = "my-firewall-logs"
              prefix = "flow-logs/"
            }
            log_destination_type = "S3"
            log_type = "FLOW"
          }
        ]
      }
    ]
  }
}

# Pass Case 3: TLS logging to Kinesis
resource "aws_networkfirewall_logging_configuration" "pass_tls_kinesis" {
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = [
          {
            log_destination = {
              deliveryStream = "my-firewall-stream"
            }
            log_destination_type = "KinesisDataFirehose"
            log_type = "TLS"
          }
        ]
      }
    ]
  }
}

# Pass Case 4: Multiple log types configured
resource "aws_networkfirewall_logging_configuration" "pass_multiple_log_types" {
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = [
          {
            log_destination = {
              logGroup = "/aws/networkfirewall/alert"
            }
            log_destination_type = "CloudWatchLogs"
            log_type = "ALERT"
          },
          {
            log_destination = {
              bucketName = "my-firewall-logs"
            }
            log_destination_type = "S3"
            log_type = "FLOW"
          },
          {
            log_destination = {
              deliveryStream = "my-firewall-stream"
            }
            log_destination_type = "KinesisDataFirehose"
            log_type = "TLS"
          }
        ]
      }
    ]
  }
}

# Fail Case 1: No log destinations configured
resource "aws_networkfirewall_logging_configuration" "fail_no_logging" {
  expect_failure = true
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = []
      }
    ]
  }
}

# Fail Case 2: Empty log destination map
resource "aws_networkfirewall_logging_configuration" "fail_empty_destination" {
  expect_failure = true
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = [
          {
            log_destination = {}
            log_destination_type = "CloudWatchLogs"
            log_type = "ALERT"
          }
        ]
      }
    ]
  }
}

# Fail Case 3: Null log destination
resource "aws_networkfirewall_logging_configuration" "fail_null_destination" {
  expect_failure = true
  attrs = {
    firewall_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall/test-firewall"
    logging_configuration = [
      {
        log_destination_config = [
          {
            log_destination = null
            log_destination_type = "S3"
            log_type = "FLOW"
          }
        ]
      }
    ]
  }
}