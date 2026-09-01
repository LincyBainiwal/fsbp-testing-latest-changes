# Copyright IBM Corp. 2026

policytest {
  targets = [
    "sns-topic-no-public-access.policy.hcl"
  ]
}

# Test 1: PASS - SNS topic policy with specific AWS account principal
resource "aws_sns_topic_policy" "pass_specific_account_principal" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowSpecificAccount\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 2: FAIL - SNS topic policy with wildcard principal and Allow effect
resource "aws_sns_topic_policy" "fail_wildcard_principal_string" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowPublic\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 3: FAIL - SNS topic policy with wildcard AWS principal
resource "aws_sns_topic_policy" "fail_wildcard_aws_principal" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowPublicAWS\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 4: PASS - SNS topic policy with wildcard principal but Deny effect
resource "aws_sns_topic_policy" "pass_wildcard_deny_effect" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"DenyPublic\",\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 5: PASS - SNS topic policy with wildcard principal but restrictive conditions
resource "aws_sns_topic_policy" "pass_wildcard_with_conditions" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowWithCondition\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringEquals\":{\"aws:SourceAccount\":\"123456789012\"}}}]}"
  }
}

# Test 6: FAIL - SNS topic with inline policy containing wildcard principal
resource "aws_sns_topic" "fail_inline_wildcard_principal" {
  expect_failure = true
  attrs = {
    name = "my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowPublic\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 7: PASS - SNS topic with inline policy containing specific account principal
resource "aws_sns_topic" "pass_inline_specific_principal" {
  attrs = {
    name = "my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowSpecificAccount\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 8: PASS - SNS topic without inline policy (filtered out by policy)
resource "aws_sns_topic" "pass_no_inline_policy" {
  attrs = {
    name = "my-topic"
    policy = null
  }
}

# Test 9: FAIL - Wildcard principal in list form: "Principal": {"AWS": ["*"]}
resource "aws_sns_topic_policy" "fail_wildcard_aws_principal_list" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowPublicList\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 10: FAIL - Wildcard principal in mixed list: "Principal": {"AWS": ["arn:...:root", "*"]}
resource "aws_sns_topic_policy" "fail_wildcard_aws_principal_mixed_list" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowMixedList\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"arn:aws:iam::123456789012:root\",\"*\"]},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 11: FAIL - NotPrincipal with Effect: Allow is effectively public
resource "aws_sns_topic_policy" "fail_not_principal_allow" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowEveryoneExcept\",\"Effect\":\"Allow\",\"NotPrincipal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 12: FAIL - Single-object Statement (not an array) with wildcard principal
resource "aws_sns_topic_policy" "fail_single_object_statement_wildcard" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":{\"Sid\":\"AllowPublicSingle\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}}"
  }
}

# Test 13: PASS - Single-object Statement (not an array) with specific principal
resource "aws_sns_topic_policy" "pass_single_object_statement_specific" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":{\"Sid\":\"AllowSpecificSingle\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}}"
  }
}

# Test 14: FAIL - Wildcard Service principal
resource "aws_sns_topic_policy" "fail_wildcard_service_principal" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowAnyService\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"*\"},\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\"}]}"
  }
}

# Test 15: FAIL - Wildcard principal with a non-restrictive Condition key.
# This policy only exempts known access-scoping keys.
resource "aws_sns_topic_policy" "fail_wildcard_non_restrictive_condition" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringLike\":{\"aws:UserAgent\":\"*curl*\"}}}]}"
  }
}

# Test 16: PASS - Wildcard principal with aws:PrincipalOrgID condition (restrictive)
resource "aws_sns_topic_policy" "pass_wildcard_org_id_condition" {
  attrs = {
    arn    = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringEquals\":{\"aws:PrincipalOrgID\":\"o-xxxx\"}}}]}"
  }
}

# Test 17: PASS - Wildcard principal with aws:SourceAccount condition (restrictive)
resource "aws_sns_topic_policy" "pass_wildcard_source_account_condition" {
  attrs = {
    arn    = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringEquals\":{\"aws:SourceAccount\":\"123456789012\"}}}]}"
  }
}

# Test 18: PASS - Wildcard principal with aws:SourceVpce condition (restrictive)
resource "aws_sns_topic_policy" "pass_wildcard_source_vpce_condition" {
  attrs = {
    arn    = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringLike\":{\"aws:SourceVpce\":\"vpce-*\"}}}]}"
  }
}

# Test 15: PASS - aws:SourceArn (StringEquals) — EventBridge/CloudWatch pattern
resource "aws_sns_topic_policy" "pass_source_arn_string_equals" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringEquals\":{\"aws:SourceArn\":\"arn:aws:events:us-east-1:123456789012:rule/my-rule\"}}}]}"
  }
}

# Test 16: PASS - aws:SourceArn (ArnLike) — common CloudWatch Alarms pattern
resource "aws_sns_topic_policy" "pass_source_arn_arnlike" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"ArnLike\":{\"aws:SourceArn\":\"arn:aws:cloudwatch:us-east-1:123456789012:alarm:*\"}}}]}"
  }
}

# Test 17: PASS - aws:SourceOrgID (StringEquals)
resource "aws_sns_topic_policy" "pass_source_org_id" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringEquals\":{\"aws:SourceOrgID\":\"o-exampleorgid\"}}}]}"
  }
}

# Test 18: PASS - aws:PrincipalOrgID under StringLike (org ID glob pattern)
resource "aws_sns_topic_policy" "pass_principal_org_id_stringlike" {
  attrs = {
    arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"SNS:Publish\",\"Resource\":\"arn:aws:sns:us-east-1:123456789012:my-topic\",\"Condition\":{\"StringLike\":{\"aws:PrincipalOrgID\":\"o-*\"}}}]}"
  }
}
