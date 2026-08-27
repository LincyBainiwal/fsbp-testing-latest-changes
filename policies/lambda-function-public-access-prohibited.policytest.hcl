# Copyright IBM Corp. 2026

policytest {
  targets = [
    "lambda-function-public-access-prohibited.policy.hcl"
  ]
}

# FAIL: wildcard principal "*"
resource "aws_lambda_permission" "fail_wildcard_principal" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "*"
    statement_id  = "AllowPublicAccess"
  }
}

# FAIL: AWS wildcard principal "AWS:*"
resource "aws_lambda_permission" "fail_aws_wildcard_principal" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "AWS:*"
    statement_id  = "AllowAWSWildcard"
  }
}

# PASS: specific AWS account
resource "aws_lambda_permission" "pass_specific_account" {
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "123456789012"
    statement_id  = "AllowSpecificAccount"
  }
}

# PASS: specific IAM principal ARN
resource "aws_lambda_permission" "pass_iam_principal" {
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "arn:aws:iam::123456789012:user/specific-user"
    statement_id  = "AllowSpecificUser"
  }
}

# FAIL: S3 service principal with no source constraint
resource "aws_lambda_permission" "fail_s3_unconstrained" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "s3.amazonaws.com"
    statement_id  = "AllowS3NoConstraint"
  }
}

# PASS: S3 service principal with source_account
resource "aws_lambda_permission" "pass_s3_with_source_account" {
  attrs = {
    function_name  = "my-function"
    action         = "lambda:InvokeFunction"
    principal      = "s3.amazonaws.com"
    source_account = "123456789012"
    statement_id   = "AllowS3WithSourceAccount"
  }
}

# PASS: S3 service principal with principal_org_id
resource "aws_lambda_permission" "pass_s3_with_org_id" {
  attrs = {
    function_name    = "my-function"
    action           = "lambda:InvokeFunction"
    principal        = "s3.amazonaws.com"
    principal_org_id = "o-1234567890"
    statement_id     = "AllowS3WithOrgId"
  }
}

# FAIL: EventBridge service principal without source constraint
resource "aws_lambda_permission" "fail_events_unconstrained" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "events.amazonaws.com"
    statement_id  = "AllowEventBridgeNoConstraint"
  }
}

# PASS: EventBridge service principal with source_arn
resource "aws_lambda_permission" "pass_events_with_source_arn" {
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "events.amazonaws.com"
    source_arn    = "arn:aws:events:us-east-1:123456789012:rule/RunDaily"
    statement_id  = "AllowEventBridgeWithSourceArn"
  }
}

# FAIL: SNS service principal without source constraint
resource "aws_lambda_permission" "fail_sns_unconstrained" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "sns.amazonaws.com"
    statement_id  = "AllowSNSNoConstraint"
  }
}

# PASS: SNS service principal with source_arn
resource "aws_lambda_permission" "pass_sns_with_source_arn" {
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "sns.amazonaws.com"
    source_arn    = "arn:aws:sns:us-east-1:123456789012:my-topic"
    statement_id  = "AllowSNSWithSourceArn"
  }
}

# PASS: S3 with both source_account and source_arn
resource "aws_lambda_permission" "pass_s3_with_both" {
  attrs = {
    function_name  = "my-function"
    action         = "lambda:InvokeFunction"
    principal      = "s3.amazonaws.com"
    source_account = "123456789012"
    source_arn     = "arn:aws:s3:::my-bucket"
    statement_id   = "AllowS3WithBoth"
  }
}

# FAIL: empty principal ""
resource "aws_lambda_permission" "fail_empty_principal" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = ""
    statement_id  = "AllowEmptyPrincipal"
  }
}

# FAIL: "AWS:" prefix with empty value
resource "aws_lambda_permission" "fail_aws_empty_principal" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "AWS:"
    statement_id  = "AllowAWSEmpty"
  }
}

# FAIL: IAM role ARN with wildcard account
resource "aws_lambda_permission" "fail_iam_arn_wildcard_account" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "arn:aws:iam::*:root"
    statement_id  = "AllowAnyAccountRoot"
  }
}

# FAIL: service principal pattern with wildcard region prefix
resource "aws_lambda_permission" "fail_wildcard_service_principal" {
  expect_failure = true
  attrs = {
    function_name = "my-function"
    action        = "lambda:InvokeFunction"
    principal     = "*.amazonaws.com"
    statement_id  = "AllowAnyService"
  }
}

