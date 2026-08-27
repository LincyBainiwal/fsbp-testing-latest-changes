# Copyright IBM Corp. 2026

# ActiveMQ brokers should stream audit logs to CloudWatch

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "mq-cloudwatch-audit-log-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_mq_broker" "activemq_audit_logs_enabled" {
    enforcement_level = input.mq-cloudwatch-audit-log-enabled-enforcement-level
    filter = core::try(attrs.engine_type, "") == "ActiveMQ"

    locals {
        audit_enabled_raw = core::try(attrs.logs[0].audit, false)
        audit_enabled = local.audit_enabled_raw == true || local.audit_enabled_raw == "true"
    }

    enforce {
        condition = local.audit_enabled == true
        error_message = "ActiveMQ broker does not have audit logging enabled. Set 'logs.audit = true' to stream audit logs to CloudWatch Logs."
    }
}
