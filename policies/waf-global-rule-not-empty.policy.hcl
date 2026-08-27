# Copyright IBM Corp. 2026

# AWS WAF Classic global rules should have at least one condition

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "waf-global-rule-not-empty-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_waf_rule" "has_conditions" {
    enforcement_level = input.waf-global-rule-not-empty-enforcement-level
    enforce {
        condition = core::length(core::try(attrs.predicates, [])) > 0
        error_message = "WAF rule does not have any conditions (predicates). Add at least one predicate to enable traffic inspection"
    }
}
