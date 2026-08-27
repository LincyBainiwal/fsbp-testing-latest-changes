# Copyright IBM Corp. 2026

# Network Firewall firewalls should have subnet change protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "network-firewall-subnet-change-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_networkfirewall_firewall" "subnet_change_protection_enabled" {
    enforcement_level = input.network-firewall-subnet-change-protection-enabled-enforcement-level
    locals {
        # Safe access to subnet_change_protection attribute with default false
        subnet_change_protection = core::try(attrs.subnet_change_protection, false)
    }

    enforce {
        condition     = local.subnet_change_protection == true
        error_message = "Network Firewall must have subnet change protection enabled. Set 'subnet_change_protection = true' to protect against accidental changes to subnet associations"
    }
}
