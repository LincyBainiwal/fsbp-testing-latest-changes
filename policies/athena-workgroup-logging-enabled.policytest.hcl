# Copyright IBM Corp. 2026

policytest {
  targets = [
    "athena-workgroup-logging-enabled.policy.hcl"
  ]
}

# ======================== PASS cases ========================

# Test 1: PASS - SQL workgroup: publish_cloudwatch_metrics_enabled = true
resource "aws_athena_workgroup" "pass_cloudwatch_metrics_enabled" {
  attrs = {
    name = "compliant-sql-workgroup"
    configuration = [
      {
        publish_cloudwatch_metrics_enabled = true
      }
    ]
  }
}

# Test 2: PASS - SQL workgroup: publish_cloudwatch_metrics_enabled = true with result config
resource "aws_athena_workgroup" "pass_cloudwatch_metrics_with_result_config" {
  attrs = {
    name = "compliant-sql-workgroup-with-s3"
    configuration = [
      {
        publish_cloudwatch_metrics_enabled = true
        result_configuration = [
          {
            output_location = "s3://my-athena-results/query-results/"
          }
        ]
      }
    ]
  }
}

# Test 3: PASS - Spark workgroup: monitoring_configuration.cloud_watch_logging_configuration enabled
resource "aws_athena_workgroup" "pass_cloudwatch_logging_enabled" {
  attrs = {
    name = "compliant-spark-workgroup-cloudwatch"
    configuration = [
      {
        monitoring_configuration = [
          {
            cloud_watch_logging_configuration = [
              {
                enabled = true
                log_group = "/aws/athena/spark-workgroup"
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 4: PASS - Spark workgroup: monitoring_configuration.s3_logging_configuration enabled
resource "aws_athena_workgroup" "pass_s3_logging_enabled" {
  attrs = {
    name = "compliant-spark-workgroup-s3"
    configuration = [
      {
        monitoring_configuration = [
          {
            s3_logging_configuration = [
              {
                enabled      = true
                log_location = "s3://my-athena-logs/spark/"
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 5: PASS - Spark workgroup: monitoring_configuration.managed_logging_configuration enabled
resource "aws_athena_workgroup" "pass_managed_logging_enabled" {
  attrs = {
    name = "compliant-spark-workgroup-managed"
    configuration = [
      {
        monitoring_configuration = [
          {
            managed_logging_configuration = [
              {
                enabled = true
              }
            ]
          }
        ]
      }
    ]
  }
}

# Test 6: PASS - All logging mechanisms enabled simultaneously
resource "aws_athena_workgroup" "pass_all_logging_enabled" {
  attrs = {
    name = "compliant-all-logging"
    configuration = [
      {
        publish_cloudwatch_metrics_enabled = true
        monitoring_configuration = [
          {
            cloud_watch_logging_configuration = [{ enabled = true }]
            s3_logging_configuration          = [{ enabled = true, log_location = "s3://logs/" }]
            managed_logging_configuration     = [{ enabled = true }]
          }
        ]
      }
    ]
  }
}

# ======================== FAIL cases ========================

# Test 7: FAIL - publish_cloudwatch_metrics_enabled = false, no monitoring_configuration
resource "aws_athena_workgroup" "fail_cloudwatch_metrics_disabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-disabled"
    configuration = [
      {
        publish_cloudwatch_metrics_enabled = false
      }
    ]
  }
}

# Test 8: FAIL - configuration block present but no logging flag set (defaults false)
resource "aws_athena_workgroup" "fail_no_logging_flag" {
  expect_failure = true
  attrs = {
    name = "non-compliant-absent-flag"
    configuration = [
      {}
    ]
  }
}

# Test 9: FAIL - no configuration block at all
resource "aws_athena_workgroup" "fail_no_configuration" {
  expect_failure = true
  attrs = {
    name = "non-compliant-no-config"
  }
}

# Test 10: FAIL - only result_configuration (S3 output), no logging enabled
resource "aws_athena_workgroup" "fail_s3_output_only" {
  expect_failure = true
  attrs = {
    name = "non-compliant-s3-output-only"
    configuration = [
      {
        result_configuration = [
          {
            output_location = "s3://my-athena-results/query-results/"
          }
        ]
      }
    ]
  }
}

# Test 11: FAIL - monitoring_configuration present but all sub-loggers disabled
resource "aws_athena_workgroup" "fail_monitoring_all_disabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-monitoring-all-disabled"
    configuration = [
      {
        monitoring_configuration = [
          {
            cloud_watch_logging_configuration = [{ enabled = false }]
            s3_logging_configuration          = [{ enabled = false }]
            managed_logging_configuration     = [{ enabled = false }]
          }
        ]
      }
    ]
  }
}