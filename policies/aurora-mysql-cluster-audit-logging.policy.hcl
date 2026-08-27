# Copyright IBM Corp. 2026

# Aurora MySQL DB clusters should have audit logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "aurora-mysql-cluster-audit-logging-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_rds_cluster" "audit_logging_enabled" {
  enforcement_level = input.aurora-mysql-cluster-audit-logging-enforcement-level
  filter = core::try(attrs.engine, "") == "aurora-mysql"
  
  locals {
    param_group_name = core::try(attrs.db_cluster_parameter_group_name, "")
    cloudwatch_logs = core::try(attrs.enabled_cloudwatch_logs_exports, [])
    audit_log_exported = core::contains(local.cloudwatch_logs, "audit")
    aurora_mysql_all_parameter_groups = core::getresources("aws_rds_cluster_parameter_group", {
      name = local.param_group_name
    })
    param_group_exists = core::length(local.aurora_mysql_all_parameter_groups) > 0
    audit_logging_param = local.param_group_exists ? [
      for param in core::try(local.aurora_mysql_all_parameter_groups[0].parameter, []) : param.value
      if param.name == "server_audit_logging"
    ] : []
    audit_logging_enabled = core::length(local.audit_logging_param) > 0 ? local.audit_logging_param[0] == "1" : false
    audit_events_param = local.param_group_exists ? [
      for param in core::try(local.aurora_mysql_all_parameter_groups[0].parameter, []) : param.value
      if param.name == "server_audit_events"
    ] : []
    audit_events_configured = core::length(local.audit_events_param) > 0 ? local.audit_events_param[0] != "" : false
  }
  
  enforce {
    condition = local.param_group_name != ""
    error_message = "Aurora MySQL cluster must have a DB cluster parameter group associated. Set 'db_cluster_parameter_group_name' to configure audit logging"
  }
  
  enforce {
    condition = local.audit_log_exported
    error_message = "Aurora MySQL cluster must export 'audit' logs to CloudWatch. Add 'audit' to 'enabled_cloudwatch_logs_exports' list"
  }
  
  enforce {
    condition = local.param_group_exists
    error_message = "Aurora MySQL cluster references parameter group which is not found in the configuration. Ensure the parameter group is defined"
  }
  
  enforce {
    condition = local.audit_logging_enabled
    error_message = "Aurora MySQL cluster parameter group must have 'server_audit_logging' set to '1'"
  }
  
  enforce {
    condition = local.audit_events_configured
    error_message = "Aurora MySQL cluster parameter group must have 'server_audit_events' configured with audit events (e.g., 'CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML'). Current value is empty or not set"
  }
}
