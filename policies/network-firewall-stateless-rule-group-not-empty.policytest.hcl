# Copyright IBM Corp. 2026

policytest {
  targets = [
    "network-firewall-stateless-rule-group-not-empty.policy.hcl"
  ]
}

resource "aws_networkfirewall_rule_group" "pass_with_single_rule" {
  attrs = {
    type = "STATELESS"
    capacity = 100
    name = "compliant-stateless-rule-group"
    rule_group = [
      {
        rules_source = [
          {
            stateless_rules_and_custom_actions = [
              {
                stateless_rule = [
                  {
                    priority = 1
                    rule_definition = [
                      {
                        actions = ["aws:pass"]
                        match_attributes = [
                          {
                            source = [
                              {
                                address_definition = "10.0.0.0/8"
                              }
                            ]
                            destination = [
                              {
                                address_definition = "192.168.0.0/16"
                              }
                            ]
                            protocols = [6]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}

resource "aws_networkfirewall_rule_group" "pass_with_multiple_rules" {
  attrs = {
    type = "STATELESS"
    capacity = 200
    name = "multiple-rules-stateless-group"
    rule_group = [
      {
        rules_source = [
          {
            stateless_rules_and_custom_actions = [
              {
                stateless_rule = [
                  {
                    priority = 1
                    rule_definition = [
                      {
                        actions = ["aws:pass"]
                        match_attributes = [
                          {
                            source = [
                              {
                                address_definition = "10.0.0.0/8"
                              }
                            ]
                            protocols = [6]
                          }
                        ]
                      }
                    ]
                  },
                  {
                    priority = 2
                    rule_definition = [
                      {
                        actions = ["aws:drop"]
                        match_attributes = [
                          {
                            source = [
                              {
                                address_definition = "0.0.0.0/0"
                              }
                            ]
                            destination_port = [
                              {
                                from_port = 22
                                to_port = 22
                              }
                            ]
                            protocols = [6]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}

resource "aws_networkfirewall_rule_group" "fail_empty_rule_group" {
  expect_failure = true
  attrs = {
    type = "STATELESS"
    capacity = 100
    name = "empty-stateless-rule-group"
    rule_group = [
      {
        rules_source = [
          {
            stateless_rules_and_custom_actions = [
              {
                stateless_rule = []
              }
            ]
          }
        ]
      }
    ]
  }
}

resource "aws_networkfirewall_rule_group" "skip_stateful_rule_group" {
  skip = true
  attrs = {
    type = "STATEFUL"
    capacity = 100
    name = "stateful-rule-group"
    rule_group = [
      {
        rules_source = [
          {
            rules_string = "pass tcp any any -> any any (sid:1;)"
          }
        ]
      }
    ]
  }
}