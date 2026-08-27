# Copyright IBM Corp. 2026

policytest {
  targets = [
    "network-firewall-deletion-protection-enabled.policy.hcl"
  ]
}

resource "aws_networkfirewall_firewall" "compliant" {
  attrs = {
    name                = "compliant-firewall"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    vpc_id              = "vpc-12345678"
    delete_protection   = true
    subnet_mapping = [
      {
        subnet_id = "subnet-12345678"
      }
    ]
  }
}

resource "aws_networkfirewall_firewall" "non_compliant" {
  expect_failure = true
  attrs = {
    name                = "non-compliant-firewall"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    vpc_id              = "vpc-12345678"
    delete_protection   = false
    subnet_mapping = [
      {
        subnet_id = "subnet-12345678"
      }
    ]
  }
}

resource "aws_networkfirewall_firewall" "default" {
  expect_failure = true
  attrs = {
    name                = "default-firewall"
    firewall_policy_arn = "arn:aws:network-firewall:us-east-1:123456789012:firewall-policy/example"
    vpc_id              = "vpc-12345678"
    subnet_mapping = [
      {
        subnet_id = "subnet-12345678"
      }
    ]
  }
}