# Copyright IBM Corp. 2026

policytest {
    targets = [
        "clb-multiple-az.policy.hcl"
    ]
}

# --------------- EC2-Classic ELB tests (availability_zones list) ---------------

# Test 1: PASS - EC2-classic ELB with 2 availability zones (minimum required)
resource "aws_elb" "pass_ec2_classic_2_azs" {
  attrs = {
    availability_zones = ["us-east-1a", "us-east-1b"]
    subnets = null
  }
}

# Test 2: PASS - EC2-classic ELB with 3 availability zones (exceeds minimum)
resource "aws_elb" "pass_ec2_classic_3_azs" {
  attrs = {
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    subnets = null
  }
}

# Test 3: FAIL - EC2-classic ELB with only 1 availability zone
resource "aws_elb" "fail_ec2_classic_1_az" {
  expect_failure = true
  attrs = {
    availability_zones = ["us-east-1a"]
    subnets = null
  }
}

# --------------- VPC ELB tests (subnets resolved to distinct AZs) ---------------
# aws_subnet resources are declared so core::getresources() can resolve them.
# The fix uses distinct availability_zone values — not raw subnet count — to
# correctly handle the case where multiple subnets share the same AZ.

resource "aws_subnet" "subnet_az1" {
  attrs = {
    id                = "subnet-12345678"
    availability_zone = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_az2" {
  attrs = {
    id                = "subnet-87654321"
    availability_zone = "us-east-1b"
  }
}

resource "aws_subnet" "subnet_az3" {
  attrs = {
    id                = "subnet-abcdef12"
    availability_zone = "us-east-1c"
  }
}

# subnet-same-az-as-1: deliberately in the same AZ as subnet_az1 (us-east-1a)
# Used to verify the distinct-AZ fix catches same-AZ subnet pairs.
resource "aws_subnet" "subnet_same_az_as_1" {
  attrs = {
    id                = "subnet-sameaz111"
    availability_zone = "us-east-1a"
  }
}

# Test 4: PASS - VPC ELB with 2 subnets each in a distinct AZ
resource "aws_elb" "pass_vpc_2_distinct_azs" {
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678", "subnet-87654321"]
  }
}

# Test 5: PASS - VPC ELB with 3 subnets each in a distinct AZ
resource "aws_elb" "pass_vpc_3_distinct_azs" {
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678", "subnet-87654321", "subnet-abcdef12"]
  }
}

# Test 6: FAIL - VPC ELB with only 1 subnet (1 distinct AZ)
resource "aws_elb" "fail_vpc_1_subnet" {
  expect_failure = true
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678"]
  }
}

# Test 7: FAIL - VPC ELB with 2 subnets both in the SAME AZ
resource "aws_elb" "fail_vpc_2_subnets_same_az" {
  expect_failure = true
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678", "subnet-sameaz111"]
  }
}