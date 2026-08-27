# Copyright IBM Corp. 2026

# Network Firewall policies should have at least one rule group associated

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "network-firewall-policy-rule-group-associated-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_networkfirewall_firewall_policy" "rule_group_required" {
    enforcement_level = input.network-firewall-policy-rule-group-associated-enforcement-level

    filter = attrs.firewall_policy != null && core::length(attrs.firewall_policy) > 0

    locals {
        firewall_policy_config = attrs.firewall_policy[0]
        
        stateful_rule_groups = core::try(local.firewall_policy_config.stateful_rule_group_reference, [])
        has_stateful_rules = core::length(local.stateful_rule_groups) > 0
        
        stateless_rule_groups = core::try(local.firewall_policy_config.stateless_rule_group_reference, [])
        has_stateless_rules = core::length(local.stateless_rule_groups) > 0
        
        has_rule_groups = local.has_stateful_rules || local.has_stateless_rules
    }

    enforce {
        condition = local.has_rule_groups
        error_message = "Network Firewall policy does not have any rule groups associated. The policy must have at least one stateful_rule_group_reference or stateless_rule_group_reference configured. Add rule groups to define traffic filtering behavior"
    }
}
