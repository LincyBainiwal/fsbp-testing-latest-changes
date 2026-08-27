# Copyright IBM Corp. 2026

# AWS WAF Classic Regional web ACLs should have at least one rule or rule group

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "waf-regional-webacl-not-empty-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_wafregional_web_acl" "has_rules" {
    enforcement_level = input.waf-regional-webacl-not-empty-enforcement-level
    enforce {
        condition = core::length(core::try(attrs.rule, [])) > 0
        error_message = "AWS WAF Regional web ACL does not contain any rules or rule groups. Web ACLs must have at least one rule to inspect and control web traffic"
    }
}
