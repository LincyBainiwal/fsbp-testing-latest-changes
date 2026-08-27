# Copyright IBM Corp. 2026

policytest{
  targets = [
    "network-firewall-policy-default-action-full-packets.policy.hcl"
  ]
}
resource "aws_networkfirewall_firewall_policy" "compliant_drop" {
  attrs = {
    name = "compliant-policy-drop"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:drop"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "compliant_forward" {
  attrs = {
    name = "compliant-policy-forward"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "compliant_both" {
  attrs = {
    name = "compliant-policy-both"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:drop", "aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "compliant_with_custom" {
  attrs = {
    name = "compliant-policy-custom"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:drop", "custom:log_action"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "non_compliant_pass" {
  expect_failure = true
  attrs = {
    name = "non-compliant-policy-pass"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:pass"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "non_compliant_mixed" {
  expect_failure = true
  attrs = {
    name = "non-compliant-policy-mixed"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:pass", "aws:drop"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "no_policy_block" {
  attrs = {
    name = "policy-without-block"
    firewall_policy = null
  }
}