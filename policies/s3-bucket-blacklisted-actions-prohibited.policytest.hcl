# Copyright IBM Corp. 2026

policytest {
    targets = [
        "s3-bucket-blacklisted-actions-prohibited.policy.hcl"
    ]
}

# Test 1: Pass - Service principal (not AWS account principal)
resource "aws_s3_bucket_policy" "pass_service_principal" {
  attrs = {
    bucket = "my-secure-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "s3:GetBucketLocation",
      "Resource": "arn:aws:s3:::my-secure-bucket"
    }
  ]
}
EOT
  }
}

# Test 2: Pass - Safe actions to external accounts (not blacklisted)
resource "aws_s3_bucket_policy" "pass_safe_actions_external" {
  attrs = {
    bucket = "my-public-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-public-bucket",
        "arn:aws:s3:::my-public-bucket/*"
      ]
    }
  ]
}
EOT
  }
}

# Test 3: Pass - Empty policy document
resource "aws_s3_bucket_policy" "pass_empty_policy" {
  attrs = {
    bucket = "my-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": []
}
EOT
  }
}

# Test 4: Fail - Wildcard principal with blacklisted action
resource "aws_s3_bucket_policy" "fail_wildcard_principal" {
  expect_failure = true
  attrs = {
    bucket = "my-insecure-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:PutBucketPolicy",
      "Resource": "arn:aws:s3:::my-insecure-bucket"
    }
  ]
}
EOT
  }
}

# Test 5: Fail - External account ARN with s3:DeleteBucketPolicy
resource "aws_s3_bucket_policy" "fail_external_delete_policy" {
  expect_failure = true
  attrs = {
    bucket = "my-vulnerable-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::987654321098:root"
      },
      "Action": "s3:DeleteBucketPolicy",
      "Resource": "arn:aws:s3:::my-vulnerable-bucket"
    }
  ]
}
EOT
  }
}

# Test 6: Fail - External account with s3:PutBucketAcl
resource "aws_s3_bucket_policy" "fail_external_put_acl" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket-acl"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::111111111111:user/external-user",
          "arn:aws:iam::222222222222:role/external-role"
        ]
      },
      "Action": "s3:PutBucketAcl",
      "Resource": "arn:aws:s3:::my-bucket-acl"
    }
  ]
}
EOT
  }
}

# Test 7: Fail - External account with s3:PutEncryptionConfiguration
resource "aws_s3_bucket_policy" "fail_external_put_encryption" {
  expect_failure = true
  attrs = {
    bucket = "my-encryption-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::555555555555:root"
      },
      "Action": "s3:PutEncryptionConfiguration",
      "Resource": "arn:aws:s3:::my-encryption-bucket"
    }
  ]
}
EOT
  }
}

# Test 8: Fail - Multiple blacklisted actions
resource "aws_s3_bucket_policy" "fail_multiple_blacklisted" {
  expect_failure = true
  attrs = {
    bucket = "my-multi-violation-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::777777777777:root"
      },
      "Action": [
        "s3:PutBucketPolicy",
        "s3:PutObjectAcl",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::my-multi-violation-bucket",
        "arn:aws:s3:::my-multi-violation-bucket/*"
      ]
    }
  ]
}
EOT
  }
}

# Test 9: Fail - Wildcard AWS principal with s3:PutObjectAcl
resource "aws_s3_bucket_policy" "fail_wildcard_aws_principal" {
  expect_failure = true
  attrs = {
    bucket = "my-wildcard-aws-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:PutObjectAcl",
      "Resource": "arn:aws:s3:::my-wildcard-aws-bucket/*"
    }
  ]
}
EOT
  }
}

# Test 10: Pass - Deny statement with external account (should not trigger)
resource "aws_s3_bucket_policy" "pass_deny_statement" {
  attrs = {
    bucket = "my-deny-bucket"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": {
        "AWS": "arn:aws:iam::999999999999:root"
      },
      "Action": "s3:DeleteBucketPolicy",
      "Resource": "arn:aws:s3:::my-deny-bucket"
    }
  ]
}
EOT
  }
}
