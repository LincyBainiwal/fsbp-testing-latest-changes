# Copyright IBM Corp. 2026

policytest {
  targets = [
    "route53-query-logging-enabled.policy.hcl"
  ]
}

# Test 1: PASS - Public hosted zone with query logging configured
resource "aws_route53_zone" "public_with_logging" {
  attrs = {
    zone_id = "Z1234567890ABC"
    name = "example.com"
    vpc = null
  }
}

resource "aws_route53_query_log" "logging" {
  attrs = {
    zone_id = "Z1234567890ABC"
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/example.com"
  }
}

# Test 2: FAIL - Public hosted zone without query logging
resource "aws_route53_zone" "public_no_logging" {
  expect_failure = true
  attrs = {
    zone_id = "Z0987654321XYZ"
    name = "nologging.com"
    vpc = null
  }
}

# Test 3: PASS - Private hosted zone (filtered out, should not be evaluated)
resource "aws_route53_zone" "private_zone" {
  attrs = {
    zone_id = "Z1111111111AAA"
    name = "internal.local"
    vpc = [
      {
        vpc_id = "vpc-12345678"
        vpc_region = "us-east-1"
      }
    ]
  }
}

# Test 4: MIXED - Multiple public zones, only some with logging
resource "aws_route53_zone" "zone1" {
  attrs = {
    zone_id = "Z1111111111111"
    name = "zone1.com"
    vpc = null
  }
}

resource "aws_route53_zone" "zone2" {
  expect_failure = true
  attrs = {
    zone_id = "Z2222222222222"
    name = "zone2.com"
    vpc = null
  }
}

resource "aws_route53_zone" "zone3" {
  attrs = {
    zone_id = "Z3333333333333"
    name = "zone3.com"
    vpc = null
  }
}

resource "aws_route53_query_log" "log1" {
  attrs = {
    zone_id = "Z1111111111111"
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/zone1.com"
  }
}

resource "aws_route53_query_log" "log3" {
  attrs = {
    zone_id = "Z3333333333333"
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/zone3.com"
  }
}

# Test 5: PASS - Public zone with empty vpc list (treated as public)
resource "aws_route53_zone" "public_empty_vpc" {
  attrs = {
    zone_id = "Z4444444444444"
    name    = "emptyvpc.com"
    vpc     = []
  }
}

resource "aws_route53_query_log" "log4" {
  attrs = {
    zone_id                  = "Z4444444444444"
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/emptyvpc.com"
  }
}

# Test 6: FAIL - Query log resource exists but cloudwatch_log_group_arn is empty
resource "aws_route53_zone" "public_zone_empty_arn" {
  expect_failure = true
  attrs = {
    zone_id = "Z5555555555555"
    name    = "emptyarn.com"
    vpc     = null
  }
}

resource "aws_route53_query_log" "log_empty_arn" {
  attrs = {
    zone_id                  = "Z5555555555555"
    cloudwatch_log_group_arn = ""
  }
}

# Test 7: FAIL - Query log resource exists but cloudwatch_log_group_arn is absent
resource "aws_route53_zone" "public_zone_missing_arn" {
  expect_failure = true
  attrs = {
    zone_id = "Z6666666666666"
    name    = "missingarn.com"
    vpc     = null
  }
}

resource "aws_route53_query_log" "log_missing_arn" {
  attrs = {
    zone_id = "Z6666666666666"
  }
}