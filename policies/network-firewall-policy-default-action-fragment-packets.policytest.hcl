# Copyright IBM Corp. 2026

policytest{
  targets = [
    "network-firewall-policy-default-action-fragment-packets"
  ]
}
resource "aws_networkfirewall_firewall_policy" "pass_with_drop_action" {
  attrs = {
    name = "secure-policy-drop"
    firewall_policy = [
      {
        stateless_fragment_default_actions = ["aws:drop"]
        stateless_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "pass_with_forward_action" {
  attrs = {
    name = "secure-policy-forward"
    firewall_policy = [
      {
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
        stateless_default_actions = ["aws:forward_to_sfe"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "fail_with_pass_action" {
  expect_failure = true
  attrs = {
    name = "insecure-policy-pass"
    firewall_policy = [
      {
        stateless_fragment_default_actions = ["aws:pass"]
        stateless_default_actions = ["aws:pass"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "fail_with_empty_actions" {
  expect_failure = true
  attrs = {
    name = "policy-empty-actions"
    firewall_policy = [
      {
        stateless_fragment_default_actions = []
        stateless_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "pass_with_drop_and_custom_action" {
  attrs = {
    name = "policy-drop-custom"
    firewall_policy = [
      {
        stateless_fragment_default_actions = ["aws:drop", "custom_action_1"]
        stateless_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "fail_with_pass_and_drop_mixed" {
  expect_failure = true
  attrs = {
    name = "policy-mixed-actions"
    firewall_policy = [
      {
        stateless_fragment_default_actions = ["aws:pass", "aws:drop"]
        stateless_default_actions = ["aws:drop"]
      }
    ]
  }
}