# Copyright IBM Corp. 2026

policytest {
  targets = [
    "s3-bucket-ssl-requests-only.policy.hcl"
  ]
}

# Test 1: PASS - Standard SSL-deny statement
resource "aws_s3_bucket_policy" "compliant_pol" {
  attrs = {
    bucket = "compliant-bucket"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowSSLRequestsOnly\",\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":[\"arn:aws:s3:::compliant-bucket\",\"arn:aws:s3:::compliant-bucket/*\"],\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "compliant" {
  attrs = {
    bucket = "compliant-bucket"
  }
}

# Test 2: PASS - Principal as object {"AWS": "*"}
resource "aws_s3_bucket_policy" "compliant_aws_principal_pol" {
  attrs = {
    bucket = "compliant-aws-principal"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":{\"AWS\":\"*\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::compliant-aws-principal/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "compliant_aws_principal" {
  attrs = {
    bucket = "compliant-aws-principal"
  }
}

# Test 3: PASS - Principal as object {"AWS": ["*"]}
resource "aws_s3_bucket_policy" "compliant_aws_principal_list_pol" {
  attrs = {
    bucket = "compliant-aws-principal-list"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::compliant-aws-principal-list/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "compliant_aws_principal_list" {
  attrs = {
    bucket = "compliant-aws-principal-list"
  }
}

# Test 4: PASS - SecureTransport as boolean false
resource "aws_s3_bucket_policy" "compliant_bool_false_pol" {
  attrs = {
    bucket = "compliant-bool-false"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::compliant-bool-false/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":false}}}]}"
  }
}

resource "aws_s3_bucket" "compliant_bool_false" {
  attrs = {
    bucket = "compliant-bool-false"
  }
}

# Test 5: PASS - Statement as a single object
resource "aws_s3_bucket_policy" "compliant_single_stmt_pol" {
  attrs = {
    bucket = "compliant-single-stmt"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::compliant-single-stmt/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}}"
  }
}

resource "aws_s3_bucket" "compliant_single_stmt" {
  attrs = {
    bucket = "compliant-single-stmt"
  }
}

# Test 6: PASS - Multiple statements, one is SSL deny
resource "aws_s3_bucket_policy" "compliant_multi_stmt_pol" {
  attrs = {
    bucket = "compliant-multi-stmt"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowList\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:ListBucket\",\"Resource\":\"arn:aws:s3:::compliant-multi-stmt\"},{\"Sid\":\"DenyInsecure\",\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":[\"arn:aws:s3:::compliant-multi-stmt\",\"arn:aws:s3:::compliant-multi-stmt/*\"],\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "compliant_multi_stmt" {
  attrs = {
    bucket = "compliant-multi-stmt"
  }
}

# Test 7: FAIL - Policy without any SecureTransport deny statement
resource "aws_s3_bucket_policy" "no_ssl_deny_pol" {
  attrs = {
    bucket = "no-ssl-deny"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowList\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:ListBucket\",\"Resource\":\"arn:aws:s3:::no-ssl-deny\"}]}"
  }
}

resource "aws_s3_bucket" "no_ssl_deny" {
  expect_failure = true
  attrs = {
    bucket = "no-ssl-deny"
  }
}

# Test 8: FAIL - Effect is Allow instead of Deny
resource "aws_s3_bucket_policy" "wrong_effect_pol" {
  attrs = {
    bucket = "wrong-effect"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::wrong-effect/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "wrong_effect" {
  expect_failure = true
  attrs = {
    bucket = "wrong-effect"
  }
}

# Test 9: FAIL - Principal is a specific ARN, not "*"
resource "aws_s3_bucket_policy" "wrong_principal_pol" {
  attrs = {
    bucket = "wrong-principal"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":{\"AWS\":\"arn:aws:iam::111122223333:root\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::wrong-principal/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "wrong_principal" {
  expect_failure = true
  attrs = {
    bucket = "wrong-principal"
  }
}

# Test 10: FAIL - SecureTransport set to "true"
resource "aws_s3_bucket_policy" "wrong_condition_value_pol" {
  attrs = {
    bucket = "wrong-condition-value"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::wrong-condition-value/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"true\"}}}]}"
  }
}

resource "aws_s3_bucket" "wrong_condition_value" {
  expect_failure = true
  attrs = {
    bucket = "wrong-condition-value"
  }
}

# Test 11: FAIL - Wrong condition operator
resource "aws_s3_bucket_policy" "wrong_condition_operator_pol" {
  attrs = {
    bucket = "wrong-condition-operator"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::wrong-condition-operator/*\",\"Condition\":{\"NumericEquals\":{\"aws:SecureTransport\":1}}}]}"
  }
}

resource "aws_s3_bucket" "wrong_condition_operator" {
  expect_failure = true
  attrs = {
    bucket = "wrong-condition-operator"
  }
}

# Test 12: FAIL - Bucket has no aws_s3_bucket_policy attached
resource "aws_s3_bucket" "no_policy" {
  expect_failure = true
  attrs = {
    bucket = "no-policy-bucket"
  }
}

# Test 13: FAIL - Action narrower than s3:*
resource "aws_s3_bucket_policy" "narrow_action_pol" {
  attrs = {
    bucket = "narrow-action"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::narrow-action/*\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "narrow_action" {
  expect_failure = true
  attrs = {
    bucket = "narrow-action"
  }
}

# Test 14: PASS - Action is a list that includes s3:*
resource "aws_s3_bucket_policy" "action_list_with_s3_star_pol" {
  attrs = {
    bucket = "action-list-with-s3-star"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":[\"s3:*\"],\"Resource\":[\"arn:aws:s3:::action-list-with-s3-star\",\"arn:aws:s3:::action-list-with-s3-star/*\"],\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "action_list_with_s3_star" {
  attrs = {
    bucket = "action-list-with-s3-star"
  }
}

# Test 15: FAIL - Deny statement targets a DIFFERENT bucket's ARN (not this bucket)

resource "aws_s3_bucket_policy" "wrong_resource_bucket_pol" {
  attrs = {
    bucket = "wrong-resource-bucket"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":[\"arn:aws:s3:::some-other-bucket\",\"arn:aws:s3:::some-other-bucket/*\"],\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "wrong_resource_bucket" {
  expect_failure = true
  attrs = {
    bucket = "wrong-resource-bucket"
  }
}

# Test 16: PASS - Resource is just the bucket ARN string (not a list, still valid)
resource "aws_s3_bucket_policy" "resource_string_bucket_arn_pol" {
  attrs = {
    bucket = "resource-string-bucket"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::resource-string-bucket\",\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
  }
}

resource "aws_s3_bucket" "resource_string_bucket" {
  attrs = {
    bucket = "resource-string-bucket"
  }
}
