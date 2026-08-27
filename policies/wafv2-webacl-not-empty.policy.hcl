# Copyright IBM Corp. 2026

# AWS WAF web ACLs should have at least one rule or rule group

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "wafv2-webacl-not-empty-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_wafv2_web_acl" "waf10_webacl_not_empty" {
    enforcement_level = input.wafv2-webacl-not-empty-enforcement-level
    locals {

        # Safely get the rule attribute, defaulting to empty list if not present
        rules = core::try(attrs.rule, [])
        
        # Check if at least one rule exists
        has_rules = core::length(local.rules) > 0
    }

    enforce {
        condition = local.has_rules
        error_message = "WAF.10 violation: Web ACL must have at least one rule or rule group. A web ACL should contain a collection of rules and rule groups that inspect and control web requests. If a web ACL is empty, the web traffic can pass without being detected or acted upon by AWS WAF depending on the default action"
    }
}
