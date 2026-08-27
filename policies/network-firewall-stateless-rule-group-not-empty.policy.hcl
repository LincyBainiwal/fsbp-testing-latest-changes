# Copyright IBM Corp. 2026

# Stateless Network Firewall rule group should not be empty

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "network-firewall-stateless-rule-group-not-empty-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_networkfirewall_rule_group" "stateless_not_empty" {
    enforcement_level = input.network-firewall-stateless-rule-group-not-empty-enforcement-level
    filter = attrs.type == "STATELESS"

    locals {
        stateless_rule_list = core::try(attrs.rule_group[0].rules_source[0].stateless_rules_and_custom_actions[0].stateless_rule, null)
        
        has_rules = local.stateless_rule_list != null && core::length(local.stateless_rule_list) > 0
    }

    enforce {
        condition = local.has_rules
        error_message = "Stateless Network Firewall rule group does not contain any rules. Add at least one stateless_rule block to rule_group.rules_source.stateless_rules_and_custom_actions to ensure the rule group processes traffic as intended"
    }
}
