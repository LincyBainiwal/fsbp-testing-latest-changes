# Copyright IBM Corp. 2026

policytest {
  targets = [
    "network-firewall-subnet-change-protection-enabled.policy.hcl"
  ]
}
# Test Case 1: PASS - Firewall with subnet_change_protection enabled
resource "aws_networkfirewall_firewall" "pass_protection_enabled" {
  attrs = {
    name                       = "compliant-firewall"
    firewall_policy_arn        = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    vpc_id                     = "vpc-12345678"
    subnet_change_protection   = true
    delete_protection          = false
    firewall_policy_change_protection = false
    subnet_mapping = [
      {
        subnet_id = "subnet-12345678"
      }
    ]
  }
}

# Test Case 2: FAIL - Firewall with subnet_change_protection explicitly disabled
resource "aws_networkfirewall_firewall" "fail_protection_disabled" {
  expect_failure = true
  attrs = {
    name                       = "non-compliant-firewall"
    firewall_policy_arn        = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    vpc_id                     = "vpc-12345678"
    subnet_change_protection   = false
    delete_protection          = false
    firewall_policy_change_protection = false
    subnet_mapping = [
      {
        subnet_id = "subnet-12345678"
      }
    ]
  }
}

# Test Case 3: FAIL - Firewall without subnet_change_protection attribute (defaults to false)
resource "aws_networkfirewall_firewall" "fail_protection_not_specified" {
  expect_failure = true
  attrs = {
    name                       = "default-firewall"
    firewall_policy_arn        = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    vpc_id                     = "vpc-12345678"
    delete_protection          = false
    firewall_policy_change_protection = false
    subnet_mapping = [
      {
        subnet_id = "subnet-12345678"
      }
    ]
  }
}