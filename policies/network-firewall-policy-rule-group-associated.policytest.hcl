# Copyright IBM Corp. 2026

policytest {
    targets = [
        "network-firewall-policy-rule-group-associated.policy.hcl"
    ]
}
resource "aws_networkfirewall_firewall_policy" "pass_with_stateful_rule_groups" {
  attrs = {
    name = "test-policy-stateful"
    firewall_policy = [
      {
        stateful_rule_group_reference = [
          {
            resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example"
            priority = 1
          }
        ]
        stateless_default_actions = ["aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "pass_with_stateless_rule_groups" {
  attrs = {
    name = "test-policy-stateless"
    firewall_policy = [
      {
        stateless_rule_group_reference = [
          {
            resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateless-rulegroup/example"
            priority = 100
          }
        ]
        stateless_default_actions = ["aws:drop"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "pass_with_both_rule_groups" {
  attrs = {
    name = "test-policy-both"
    firewall_policy = [
      {
        stateful_rule_group_reference = [
          {
            resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example"
            priority = 1
          }
        ]
        stateless_rule_group_reference = [
          {
            resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateless-rulegroup/example"
            priority = 100
          }
        ]
        stateless_default_actions = ["aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "fail_without_rule_groups" {
  expect_failure = true
  attrs = {
    name = "test-policy-no-rules"
    firewall_policy = [
      {
        stateless_default_actions = ["aws:drop"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "fail_with_empty_rule_groups" {
  expect_failure = true
  attrs = {
    name = "test-policy-empty-rules"
    firewall_policy = [
      {
        stateful_rule_group_reference = []
        stateless_rule_group_reference = []
        stateless_default_actions = ["aws:drop"]
        stateless_fragment_default_actions = ["aws:drop"]
      }
    ]
  }
}

resource "aws_networkfirewall_firewall_policy" "pass_with_multiple_stateful_rule_groups" {
  attrs = {
    name = "test-policy-multiple-stateful"
    firewall_policy = [
      {
        stateful_rule_group_reference = [
          {
            resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example1"
            priority = 1
          },
          {
            resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example2"
            priority = 2
          }
        ]
        stateless_default_actions = ["aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      }
    ]
  }
}