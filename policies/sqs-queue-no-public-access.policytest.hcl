# Copyright IBM Corp. 2026

policytest{
  targets = [
    "sqs-queue-no-public-access.policy.hcl"
  ]
}

# --------------- PASS cases ---------------

# Test 1: PASS - Policy with a specific AWS account principal (not a wildcard)
resource "aws_sqs_queue_policy" "pass_specific_account_principal" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"sqs:*\",\"Resource\":\"*\"}]}"
  }
}

# Test 2: PASS - Wildcard principal BUT a restrictive Condition narrows access
resource "aws_sqs_queue_policy" "pass_wildcard_with_condition" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\",\"Condition\":{\"StringEquals\":{\"aws:PrincipalOrgID\":\"o-exampleorgid\"}}}]}"
  }
}

# Test 3: PASS - Inline policy with a specific role principal (not a wildcard)
resource "aws_sqs_queue" "pass_inline_specific_principal" {
  attrs = {
    name = "my-compliant-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:role/MyRole\"},\"Action\":\"sqs:*\",\"Resource\":\"*\"}]}"
  }
}

# Test 4: PASS - Queue with no policy attribute (filtered out, not evaluated)
resource "aws_sqs_queue" "pass_no_policy" {
  attrs = {
    name = "my-queue-no-policy"
  }
}

# Test 5: PASS - Queue policy resource with no policy attribute (filtered out)
resource "aws_sqs_queue_policy" "pass_no_policy_attr" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
  }
}

# --------------- FAIL cases ---------------

# Test 6: FAIL - Policy with Principal="*" and no Condition
resource "aws_sqs_queue_policy" "fail_wildcard_principal" {
  expect_failure = true
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 7: FAIL - Policy with Principal.AWS="*" and no Condition
resource "aws_sqs_queue_policy" "fail_wildcard_principal_aws" {
  expect_failure = true
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":\"sqs:ReceiveMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 8: FAIL - Inline queue policy with Principal="*" and no Condition
resource "aws_sqs_queue" "fail_inline_wildcard_principal" {
  expect_failure = true
  attrs = {
    name = "my-public-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 9: FAIL - Principal.AWS in list form ["*"] — must be caught same as string "*"
resource "aws_sqs_queue_policy" "fail_wildcard_aws_list_form" {
  expect_failure = true
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\"}]}"
  }
}

# Test 10: PASS - empty-string policy value is filtered out 
resource "aws_sqs_queue_policy" "pass_empty_string_policy" {
  attrs = {
    queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/my-queue"
    policy    = ""
  }
}