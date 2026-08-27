# Copyright IBM Corp. 2026

policytest {
    targets = [
        "rds-instance-subnet-igw-check.policy.hcl"
    ]
}

# Test 1: PASS - RDS instance in private subnet without IGW route
resource "aws_db_subnet_group" "private_subnet_group" {
  skip = true
  attrs = {
    name = "private-subnet-group"
    subnet_ids = ["subnet-private-1", "subnet-private-2"]
  }
}

resource "aws_route_table" "private_route_table" {
  skip = true
  attrs = {
    id = "rtb-private-123"
    vpc_id = "vpc-123"
    route = [
      {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
      },
      {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "nat-12345678"
      }
    ]
  }
}

resource "aws_route_table_association" "private_assoc_1" {
  skip = true
  attrs = {
    subnet_id = "subnet-private-1"
    route_table_id = "rtb-private-123"
  }
}

resource "aws_route_table_association" "private_assoc_2" {
  skip = true
  attrs = {
    subnet_id = "subnet-private-2"
    route_table_id = "rtb-private-123"
  }
}

resource "aws_db_instance" "pass_private_subnet" {
  attrs = {
    db_subnet_group_name = "private-subnet-group"
    identifier = "test-db-private"
  }
}

# Test 2: FAIL - RDS instance in subnet with IGW route to 0.0.0.0/0
resource "aws_db_subnet_group" "public_subnet_group" {
  skip = true
  attrs = {
    name = "public-subnet-group"
    subnet_ids = ["subnet-public-1", "subnet-public-2"]
  }
}

resource "aws_route_table" "public_route_table" {
  skip = true
  attrs = {
    id = "rtb-public-123"
    vpc_id = "vpc-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw-12345678"
      }
    ]
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  skip = true
  attrs = {
    subnet_id = "subnet-public-1"
    route_table_id = "rtb-public-123"
  }
}

resource "aws_route_table_association" "public_assoc_2" {
  skip = true
  attrs = {
    subnet_id = "subnet-public-2"
    route_table_id = "rtb-public-123"
  }
}

resource "aws_db_instance" "fail_public_subnet_with_igw" {
  expect_failure = true
  attrs = {
    db_subnet_group_name = "public-subnet-group"
    identifier = "test-db-public"
  }
}

# Test 3: PASS - RDS instance in subnet with NAT gateway (not IGW)
resource "aws_db_subnet_group" "nat_subnet_group" {
  skip = true
  attrs = {
    name = "nat-subnet-group"
    subnet_ids = ["subnet-nat-1", "subnet-nat-2"]
  }
}

resource "aws_route_table" "nat_route_table" {
  skip = true
  attrs = {
    id = "rtb-nat-123"
    vpc_id = "vpc-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "nat-12345678"
      }
    ]
  }
}

resource "aws_route_table_association" "nat_assoc_1" {
  skip = true
  attrs = {
    subnet_id = "subnet-nat-1"
    route_table_id = "rtb-nat-123"
  }
}

resource "aws_route_table_association" "nat_assoc_2" {
  skip = true
  attrs = {
    subnet_id = "subnet-nat-2"
    route_table_id = "rtb-nat-123"
  }
}

resource "aws_db_instance" "pass_nat_gateway" {
  attrs = {
    db_subnet_group_name = "nat-subnet-group"
    identifier = "test-db-nat"
  }
}

# Test 4: FAIL - RDS instance in mixed subnet group (one subnet has IGW)
resource "aws_db_subnet_group" "mixed_subnet_group" {
  skip = true
  attrs = {
    name = "mixed-subnet-group"
    subnet_ids = ["subnet-mixed-1", "subnet-mixed-2"]
  }
}

resource "aws_route_table" "mixed_route_table_private" {
  skip = true
  attrs = {
    id = "rtb-mixed-private-123"
    vpc_id = "vpc-123"
    route = [
      {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
      }
    ]
  }
}

resource "aws_route_table" "mixed_route_table_public" {
  skip = true
  attrs = {
    id = "rtb-mixed-public-123"
    vpc_id = "vpc-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw-87654321"
      }
    ]
  }
}

resource "aws_route_table_association" "mixed_assoc_1" {
  skip = true
  attrs = {
    subnet_id = "subnet-mixed-1"
    route_table_id = "rtb-mixed-private-123"
  }
}

resource "aws_route_table_association" "mixed_assoc_2" {
  skip = true
  attrs = {
    subnet_id = "subnet-mixed-2"
    route_table_id = "rtb-mixed-public-123"
  }
}

resource "aws_db_instance" "fail_mixed_subnet_group" {
  expect_failure = true
  attrs = {
    db_subnet_group_name = "mixed-subnet-group"
    identifier = "test-db-mixed"
  }
}

# Test 5: PASS - RDS instance with empty route table
resource "aws_db_subnet_group" "empty_routes_subnet_group" {
  skip = true
  attrs = {
    name = "empty-routes-subnet-group"
    subnet_ids = ["subnet-empty-1"]
  }
}

resource "aws_route_table" "empty_route_table" {
  skip = true
  attrs = {
    id = "rtb-empty-123"
    vpc_id = "vpc-123"
    route = []
  }
}

resource "aws_route_table_association" "empty_assoc" {
  skip = true
  attrs = {
    subnet_id = "subnet-empty-1"
    route_table_id = "rtb-empty-123"
  }
}

resource "aws_db_instance" "pass_empty_routes" {
  attrs = {
    db_subnet_group_name = "empty-routes-subnet-group"
    identifier = "test-db-empty-routes"
  }
}

# Test 6: PASS - RDS instance in subnet with IGW route but not to 0.0.0.0/0 (not public)
resource "aws_db_subnet_group" "igw_non_public_subnet_group" {
  skip = true
  attrs = {
    name = "igw-non-public-subnet-group"
    subnet_ids = ["subnet-igw-non-public-1"]
  }
}

resource "aws_route_table" "igw_non_public_route_table" {
  skip = true
  attrs = {
    id = "rtb-igw-non-public-123"
    vpc_id = "vpc-123"
    route = [
      {
        cidr_block = "10.0.0.0/8"
        gateway_id = "igw-12345678"
      }
    ]
  }
}

resource "aws_route_table_association" "igw_non_public_assoc" {
  skip = true
  attrs = {
    subnet_id = "subnet-igw-non-public-1"
    route_table_id = "rtb-igw-non-public-123"
  }
}

resource "aws_db_instance" "pass_igw_non_public" {
  attrs = {
    db_subnet_group_name = "igw-non-public-subnet-group"
    identifier = "test-db-igw-non-public"
  }
}

# Test 7: FAIL - RDS instance in subnet with IPv6 public route to IGW
resource "aws_db_subnet_group" "ipv6_public_subnet_group" {
  skip = true
  attrs = {
    name = "ipv6-public-subnet-group"
    subnet_ids = ["subnet-ipv6-public-1"]
  }
}

resource "aws_route_table" "ipv6_public_route_table" {
  skip = true
  attrs = {
    id = "rtb-ipv6-public-123"
    vpc_id = "vpc-123"
    route = [
      {
        ipv6_cidr_block = "::/0"
        gateway_id = "igw-ipv6-12345"
      }
    ]
  }
}

resource "aws_route_table_association" "ipv6_public_assoc" {
  skip = true
  attrs = {
    subnet_id = "subnet-ipv6-public-1"
    route_table_id = "rtb-ipv6-public-123"
  }
}

resource "aws_db_instance" "fail_ipv6_public_subnet" {
  expect_failure = true
  attrs = {
    db_subnet_group_name = "ipv6-public-subnet-group"
    identifier = "test-db-ipv6-public"
  }
}


# Test 8: FAIL - RDS instance without db_subnet_group_name (unset/null)
# When db_subnet_group_name is unset, we cannot evaluate subnet topology during plan
# Policy fails closed to prevent false negatives
resource "aws_db_instance" "fail_unset_subnet_group" {
  expect_failure = true
  attrs = {
    identifier = "test-db-unset-group"
    # db_subnet_group_name is intentionally omitted
  }
}

# Test 9: FAIL - RDS instance using VPC main route table with IGW (no explicit association)
# This tests the fix for subnets inheriting the VPC main route table
resource "aws_db_subnet_group" "main_route_table_subnet_group" {
  skip = true
  attrs = {
    name = "main-route-table-subnet-group"
    subnet_ids = ["subnet-main-rt-1", "subnet-main-rt-2"]
  }
}

resource "aws_subnet" "main_rt_subnet_1" {
  skip = true
  attrs = {
    id = "subnet-main-rt-1"
    vpc_id = "vpc-main-123"
  }
}

resource "aws_subnet" "main_rt_subnet_2" {
  skip = true
  attrs = {
    id = "subnet-main-rt-2"
    vpc_id = "vpc-main-123"
  }
}

# VPC main route table with IGW route
resource "aws_route_table" "main_route_table_with_igw" {
  skip = true
  attrs = {
    id = "rtb-main-123"
    vpc_id = "vpc-main-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw-main-123"
      }
    ]
  }
}

# Main route table association for the VPC
resource "aws_main_route_table_association" "main_rt_assoc" {
  skip = true
  attrs = {
    vpc_id = "vpc-main-123"
    route_table_id = "rtb-main-123"
  }
}

# No explicit aws_route_table_association for the subnets
# They inherit the VPC main route table

resource "aws_db_instance" "fail_main_route_table_with_igw" {
  expect_failure = true
  attrs = {
    db_subnet_group_name = "main-route-table-subnet-group"
    identifier = "test-db-main-rt-igw"
  }
}

# Test 10: PASS - RDS instance using VPC main route table without IGW
resource "aws_db_subnet_group" "main_route_table_private_subnet_group" {
  skip = true
  attrs = {
    name = "main-route-table-private-subnet-group"
    subnet_ids = ["subnet-main-rt-private-1"]
  }
}

resource "aws_subnet" "main_rt_private_subnet_1" {
  skip = true
  attrs = {
    id = "subnet-main-rt-private-1"
    vpc_id = "vpc-main-private-123"
  }
}

resource "aws_route_table" "main_route_table_private" {
  skip = true
  attrs = {
    id = "rtb-main-private-123"
    vpc_id = "vpc-main-private-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "nat-main-123"
      }
    ]
  }
}

resource "aws_main_route_table_association" "main_rt_private_assoc" {
  skip = true
  attrs = {
    vpc_id = "vpc-main-private-123"
    route_table_id = "rtb-main-private-123"
  }
}

resource "aws_db_instance" "pass_main_route_table_private" {
  attrs = {
    db_subnet_group_name = "main-route-table-private-subnet-group"
    identifier = "test-db-main-rt-private"
  }
}

# Test 11: FAIL - RDS instance with unresolved subnet group (external/not in config)
# Policy fails closed when subnet group cannot be resolved
resource "aws_db_instance" "fail_unresolved_subnet_group" {
  expect_failure = true
  attrs = {
    db_subnet_group_name = "external-subnet-group-not-in-config"
    identifier = "test-db-unresolved"
  }
}

# Test 12: FAIL - Mixed scenario: one subnet explicit (private), one subnet inherits main RT (public)
resource "aws_db_subnet_group" "mixed_explicit_main_subnet_group" {
  skip = true
  attrs = {
    name = "mixed-explicit-main-subnet-group"
    subnet_ids = ["subnet-mixed-explicit", "subnet-mixed-main"]
  }
}

resource "aws_subnet" "mixed_explicit_subnet" {
  skip = true
  attrs = {
    id = "subnet-mixed-explicit"
    vpc_id = "vpc-mixed-123"
  }
}

resource "aws_subnet" "mixed_main_subnet" {
  skip = true
  attrs = {
    id = "subnet-mixed-main"
    vpc_id = "vpc-mixed-123"
  }
}

# Private route table for explicit association
resource "aws_route_table" "mixed_explicit_private" {
  skip = true
  attrs = {
    id = "rtb-mixed-explicit-123"
    vpc_id = "vpc-mixed-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "nat-mixed-123"
      }
    ]
  }
}

# Explicit association for first subnet (private)
resource "aws_route_table_association" "mixed_explicit_assoc" {
  skip = true
  attrs = {
    subnet_id = "subnet-mixed-explicit"
    route_table_id = "rtb-mixed-explicit-123"
  }
}

# Main route table with IGW (inherited by second subnet)
resource "aws_route_table" "mixed_main_public" {
  skip = true
  attrs = {
    id = "rtb-mixed-main-123"
    vpc_id = "vpc-mixed-123"
    route = [
      {
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw-mixed-123"
      }
    ]
  }
}

resource "aws_main_route_table_association" "mixed_main_assoc" {
  skip = true
  attrs = {
    vpc_id = "vpc-mixed-123"
    route_table_id = "rtb-mixed-main-123"
  }
}

# No explicit association for subnet-mixed-main, so it inherits the main RT with IGW

resource "aws_db_instance" "fail_mixed_explicit_main" {
  expect_failure = true
  attrs = {
    db_subnet_group_name = "mixed-explicit-main-subnet-group"
    identifier = "test-db-mixed-explicit-main"
  }
}
