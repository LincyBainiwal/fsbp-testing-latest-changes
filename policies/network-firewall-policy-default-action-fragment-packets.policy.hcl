# Copyright IBM Corp. 2026

# The default stateless action for Network Firewall policies should be drop or forward for fragmented packets

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "network-firewall-policy-default-action-fragment-packets-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_networkfirewall_firewall_policy" "fragment_default_action" {
    enforcement_level = input.network-firewall-policy-default-action-fragment-packets-enforcement-level
    filter = attrs.firewall_policy != null && core::length(attrs.firewall_policy) > 0

    locals {
        firewall_policy_config = attrs.firewall_policy[0]
        
        fragment_actions = core::try(local.firewall_policy_config.stateless_fragment_default_actions, [])
        
        has_pass_action = core::contains(local.fragment_actions, "aws:pass")
        
        has_drop = core::contains(local.fragment_actions, "aws:drop")
        has_forward = core::contains(local.fragment_actions, "aws:forward_to_sfe")
        has_valid_action = local.has_drop || local.has_forward
        
        actions_string = core::join(", ", local.fragment_actions)
    }

    enforce {
        condition = core::length(local.fragment_actions) > 0
        error_message = "Network Firewall policy does not have 'stateless_fragment_default_actions' defined. This is a required attribute. Set it to ['aws:drop'] or ['aws:forward_to_sfe']"
    }

    enforce {
        condition = !local.has_pass_action
        error_message = "Network Firewall policy has 'aws:pass' in stateless_fragment_default_actions [${local.actions_string}]. This allows unintended fragmented traffic. Change to ['aws:drop'] or ['aws:forward_to_sfe']"
    }

    enforce {
        condition = local.has_valid_action
        error_message = "Network Firewall policy must use 'aws:drop' or 'aws:forward_to_sfe' for stateless_fragment_default_actions. Current actions: [${local.actions_string}]"
    }
}
