# Copyright IBM Corp. 2026

# The default stateless action for Network Firewall policies should be drop or forward for full packets

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "network-firewall-policy-default-action-full-packets-enforcement-level" {
  type = string
  default = "advisory"
}

input "statelessDefaultActions" {
    type = string
    default = "aws:drop,aws:forward_to_sfe"
}

resource_policy "aws_networkfirewall_firewall_policy" "stateless_default_action_check" {
    enforcement_level = input.network-firewall-policy-default-action-full-packets-enforcement-level
    filter = attrs.firewall_policy != null

    locals {
        input_matches_supported_values = input.statelessDefaultActions == "aws:drop,aws:forward_to_sfe" || input.statelessDefaultActions == "aws:forward_to_sfe,aws:drop"
        stateless_actions = core::try(attrs.firewall_policy[0].stateless_default_actions, [])
        stateless_actions_display = core::join(", ", local.stateless_actions)
        
        has_pass_action = core::contains(local.stateless_actions, "aws:pass")
        
        has_drop = core::contains(local.stateless_actions, "aws:drop")
        has_forward = core::contains(local.stateless_actions, "aws:forward_to_sfe")
        has_compliant_action = local.has_drop || local.has_forward
        
        is_compliant = local.has_compliant_action && !local.has_pass_action
    }

    enforce {
        condition = local.input_matches_supported_values
        error_message = "input.statelessDefaultActions must remain 'aws:drop,aws:forward_to_sfe' because this AWS control is not customizable"
    }

    enforce {
        condition = local.is_compliant
        error_message = "Network Firewall policy has non-compliant stateless default action. Current actions: ${local.stateless_actions_display}. The allowed full-packet default actions from input.statelessDefaultActions='${input.statelessDefaultActions}' are aws:drop and aws:forward_to_sfe. The policy fails if aws:pass is selected. Update 'stateless_default_actions' to use a compliant action"
    }
}
