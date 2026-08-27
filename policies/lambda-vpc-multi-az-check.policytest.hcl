# Copyright IBM Corp. 2026

policytest {
  targets = ["lambda-vpc-multi-az-check.policy.hcl"]
}

# Pass case: Lambda with subnets in 2 different AZs (meets minimum requirement)
resource "aws_lambda_function" "compliant_two_az" {
  attrs = {
    function_name = "compliant-function-two-az"
    role = "arn:aws:iam::123456789012:role/lambda-role"
    vpc_config = [
      {
        subnet_ids = ["subnet-abc123", "subnet-def456"]
        security_group_ids = ["sg-123456"]
      }
    ]
  }
}

resource "aws_subnet" "subnet_az1" {
  skip = true
  attrs = {
    id = "subnet-abc123"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_az2" {
  skip = true
  attrs = {
    id = "subnet-def456"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
  }
}

# Pass case: Lambda with subnets in 3 different AZs (exceeds minimum)
resource "aws_lambda_function" "compliant_three_az" {
  attrs = {
    function_name = "compliant-function-three-az"
    role = "arn:aws:iam::123456789012:role/lambda-role"
    vpc_config = [
      {
        subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
        security_group_ids = ["sg-123456"]
      }
    ]
  }
}

resource "aws_subnet" "subnet_az1_three" {
  skip = true
  attrs = {
    id = "subnet-111"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_az2_three" {
  skip = true
  attrs = {
    id = "subnet-222"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
  }
}

resource "aws_subnet" "subnet_az3_three" {
  skip = true
  attrs = {
    id = "subnet-333"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
  }
}

# Pass case: Lambda without VPC configuration (filtered out, not evaluated)
resource "aws_lambda_function" "no_vpc" {
  attrs = {
    function_name = "non-vpc-function"
    role = "arn:aws:iam::123456789012:role/lambda-role"
    # No vpc_config block - should be filtered out
  }
}

# Fail case: Lambda with multiple subnets all in the same AZ
resource "aws_lambda_function" "non_compliant_single_az" {
  expect_failure = true
  attrs = {
    function_name = "non-compliant-function-single-az"
    role = "arn:aws:iam::123456789012:role/lambda-role"
    vpc_config = [
      {
        subnet_ids = ["subnet-aaa", "subnet-bbb"]
        security_group_ids = ["sg-123456"]
      }
    ]
  }
}

resource "aws_subnet" "subnet1_same_az" {
  skip = true
  attrs = {
    id = "subnet-aaa"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
}

resource "aws_subnet" "subnet2_same_az" {
  skip = true
  attrs = {
    id = "subnet-bbb"
    vpc_id = "vpc-123456"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
  }
}

# Fail case: Lambda with subnets but missing subnet resource data
resource "aws_lambda_function" "missing_subnet_info" {
  expect_failure = true
  attrs = {
    function_name = "function-missing-subnet-data"
    role = "arn:aws:iam::123456789012:role/lambda-role"
    vpc_config = [
      {
        subnet_ids = ["subnet-xyz789"]
        security_group_ids = ["sg-123456"]
      }
    ]
  }
  # No corresponding aws_subnet resource - cannot determine AZ
}