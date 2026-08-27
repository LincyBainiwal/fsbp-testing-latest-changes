# Copyright IBM Corp. 2026

# AWS WAF Classic Regional rule groups should have at least one rule

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "waf-regional-rulegroup-not-empty-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_wafregional_rule_group" "has_rules" {
    enforcement_level = input.waf-regional-rulegroup-not-empty-enforcement-level
    locals {
        activated_rules = core::try(attrs.activated_rule, [])
    }

    enforce {
        condition = core::length(local.activated_rules) > 0
        error_message = "WAF Regional rule group has no activated rules. A rule group must have at least one activated rule to ensure proper traffic inspection"
    }
}
