# Copyright IBM Corp. 2026

policytest {
    targets = [
        "redshift-unrestricted-port-access.policy.hcl"
    ]
}

# Test 1: PASS - No security groups attached to cluster
resource "aws_redshift_cluster" "pass_no_security_groups" {
  attrs = {
    cluster_identifier = "test-cluster-no-sg"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
  }
}

# Test 2: PASS - Security group with restricted access (specific CIDR)
resource "aws_redshift_cluster" "pass_restricted_access" {
  attrs = {
    cluster_identifier = "test-cluster-restricted"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-restricted"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "restricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-restricted"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "10.0.0.0/16"
  }
}

# Test 3: PASS - Security group with restricted IPv6 access
resource "aws_redshift_cluster" "pass_restricted_ipv6" {
  attrs = {
    cluster_identifier = "test-cluster-restricted-ipv6"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-restricted-ipv6"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "restricted_ipv6_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-restricted-ipv6"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv6 = "2001:db8::/32"
  }
}

# Test 4: PASS - Security group with different port (not Redshift port)
resource "aws_redshift_cluster" "pass_different_port" {
  attrs = {
    cluster_identifier = "test-cluster-diff-port"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-diff-port"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "different_port_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-diff-port"
    ip_protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 5: PASS - Custom Redshift port with restricted access
resource "aws_redshift_cluster" "pass_custom_port_restricted" {
  attrs = {
    cluster_identifier = "test-cluster-custom-port"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-custom-port"]
    port = 6439
  }
}

resource "aws_vpc_security_group_ingress_rule" "custom_port_restricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-custom-port"
    ip_protocol = "tcp"
    from_port = 6439
    to_port = 6439
    cidr_ipv4 = "192.168.1.0/24"
  }
}

# Test 6: FAIL - Security group with unrestricted IPv4 access (0.0.0.0/0)
resource "aws_redshift_cluster" "fail_unrestricted_ipv4" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-unrestricted-ipv4"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-unrestricted-ipv4"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "unrestricted_ipv4_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-unrestricted-ipv4"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 7: FAIL - Security group with unrestricted IPv6 access (::/0)
resource "aws_redshift_cluster" "fail_unrestricted_ipv6" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-unrestricted-ipv6"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-unrestricted-ipv6"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "unrestricted_ipv6_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-unrestricted-ipv6"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv6 = "::/0"
  }
}

# Test 8: FAIL - Security group with port range covering Redshift port and unrestricted access
resource "aws_redshift_cluster" "fail_port_range_unrestricted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-port-range"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-port-range"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "port_range_unrestricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-port-range"
    ip_protocol = "tcp"
    from_port = 5000
    to_port = 6000
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 9: FAIL - Security group with all protocols (-1) and unrestricted access
resource "aws_redshift_cluster" "fail_all_protocols_unrestricted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-all-protocols"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-all-protocols"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "all_protocols_unrestricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-all-protocols"
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 10: FAIL - Custom port with unrestricted access
resource "aws_redshift_cluster" "fail_custom_port_unrestricted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-custom-unrestricted"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-custom-unrestricted"]
    port = 7439
  }
}

resource "aws_vpc_security_group_ingress_rule" "custom_port_unrestricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-custom-unrestricted"
    ip_protocol = "tcp"
    from_port = 7439
    to_port = 7439
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 11: FAIL - Multiple security groups, one with unrestricted access
resource "aws_redshift_cluster" "fail_multiple_sgs_one_unrestricted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-multi-sg"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-restricted-multi", "sg-unrestricted-multi"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "restricted_multi_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-restricted-multi"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "10.0.0.0/16"
  }
}

resource "aws_vpc_security_group_ingress_rule" "unrestricted_multi_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-unrestricted-multi"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 12: PASS - Multiple security groups, all with restricted access
resource "aws_redshift_cluster" "pass_multiple_sgs_all_restricted" {
  attrs = {
    cluster_identifier = "test-cluster-multi-restricted"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-restricted-1", "sg-restricted-2"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "restricted_1_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-restricted-1"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "10.0.0.0/16"
  }
}

resource "aws_vpc_security_group_ingress_rule" "restricted_2_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-restricted-2"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "172.16.0.0/12"
  }
}

# Test 13: FAIL - Security group with multiple rules, one unrestricted
resource "aws_redshift_cluster" "fail_sg_multiple_rules_one_unrestricted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-multi-rules"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-multi-rules"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "multi_rules_restricted" {
  skip = true
  attrs = {
    security_group_id = "sg-multi-rules"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "10.0.0.0/16"
  }
}

resource "aws_vpc_security_group_ingress_rule" "multi_rules_unrestricted" {
  skip = true
  attrs = {
    security_group_id = "sg-multi-rules"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 14: PASS - Default Redshift port (5439) with restricted access
resource "aws_redshift_cluster" "pass_default_port_restricted" {
  attrs = {
    cluster_identifier = "test-cluster-default-port"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-default-port"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "default_port_restricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-default-port"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "203.0.113.0/24"
  }
}

# Test 15: FAIL - Port range starting before and ending after Redshift port with unrestricted access
resource "aws_redshift_cluster" "fail_wide_port_range_unrestricted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "test-cluster-wide-range"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-wide-range"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "wide_range_unrestricted_rule" {
  skip = true
  attrs = {
    security_group_id = "sg-wide-range"
    ip_protocol = "tcp"
    from_port = 1
    to_port = 65535
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# Test 16: PASS - Multiple security groups but only some have ingress rules defined (missing rules should not cause failure)
resource "aws_redshift_cluster" "pass_multiple_sgs_partial_rules_defined" {
  attrs = {
    cluster_identifier = "test-cluster-partial-rules"
    node_type = "dc2.large"
    master_username = "admin"
    database_name = "mydb"
    vpc_security_group_ids = ["sg-with-rules", "sg-without-rules", "sg-another-without-rules"]
    port = 5439
  }
}

resource "aws_vpc_security_group_ingress_rule" "with_rules_restricted" {
  skip = true
  attrs = {
    security_group_id = "sg-with-rules"
    ip_protocol = "tcp"
    from_port = 5439
    to_port = 5439
    cidr_ipv4 = "10.0.0.0/16"
  }
}
