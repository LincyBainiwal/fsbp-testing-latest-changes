# Copyright IBM Corp. 2026

policytest {
  targets = [
    "waf-classic-logging-enabled.policy.hcl"
  ]
}

# Test 1: PASS - WAF Web ACL with proper logging configuration
resource "aws_waf_web_acl" "pass_with_valid_logging_and_firehose" {
  attrs = {
    name = "example-web-acl"
    metric_name = "exampleWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
    logging_configuration = [{
      log_destination = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-example"
      redacted_fields = []
    }]
  }
}

resource "aws_kinesis_firehose_delivery_stream" "pass_valid_stream" {
  attrs = {
    name = "aws-waf-logs-example"
    destination = "extended_s3"
    region = "us-east-1"
    extended_s3_configuration = [{
      role_arn = "arn:aws:iam::123456789012:role/firehose-role"
      bucket_arn = "arn:aws:s3:::waf-logs-bucket"
    }]
  }
}

# Test 2: FAIL - WAF Web ACL without logging_configuration
resource "aws_waf_web_acl" "fail_without_logging_configuration" {
  expect_failure = true
  attrs = {
    name = "no-logging-web-acl"
    metric_name = "noLoggingWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
  }
}

# Test 3: FAIL - WAF Web ACL with empty log_destination
resource "aws_waf_web_acl" "fail_with_empty_log_destination" {
  expect_failure = true
  attrs = {
    name = "empty-destination-web-acl"
    metric_name = "emptyDestinationWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
    logging_configuration = [{
      log_destination = ""
      redacted_fields = []
    }]
  }
}
