# Copyright IBM Corp. 2026

# DynamoDB tables should automatically scale capacity with demand

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dynamodb-autoscaling-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

input "minProvisionedReadCapacity" {
  type    = number
  default = 0
}

input "targetReadUtilization" {
  type    = number
  default = 0
}

input "minProvisionedWriteCapacity" {
  type    = number
  default = 0
}

input "targetWriteUtilization" {
  type    = number
  default = 0
}

resource_policy "aws_dynamodb_table" "autoscaling_enabled" {
  enforcement_level = input.dynamodb-autoscaling-enabled-enforcement-level
  # Skip on-demand (PAY_PER_REQUEST) tables — AWS Security Hub DynamoDB.1 only applies
  # to PROVISIONED tables. On-demand tables scale automatically by design and are
  # always compliant for this control.
  filter = core::try(attrs.billing_mode, "PROVISIONED") == "PROVISIONED"

  locals {
    table_name = core::try(attrs.name, "")
    read_scaling_targets = core::getresources("aws_appautoscaling_target", {
      resource_id        = "table/${local.table_name}"
      scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    })
    write_scaling_targets = core::getresources("aws_appautoscaling_target", {
      resource_id        = "table/${local.table_name}"
      scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    })

    has_read_autoscaling  = core::length(local.read_scaling_targets) > 0
    has_write_autoscaling = core::length(local.write_scaling_targets) > 0
    has_autoscaling       = local.has_read_autoscaling && local.has_write_autoscaling

    # Optional AWS Config-style parameter validation. A value of 0 means "not provided".
    has_min_read_capacity        = input.minProvisionedReadCapacity > 0
    has_target_read_utilization  = input.targetReadUtilization > 0
    has_min_write_capacity       = input.minProvisionedWriteCapacity > 0
    has_target_write_utilization = input.targetWriteUtilization > 0

    valid_min_read_capacity        = !local.has_min_read_capacity || (input.minProvisionedReadCapacity >= 1 && input.minProvisionedReadCapacity <= 40000)
    valid_target_read_utilization  = !local.has_target_read_utilization || (input.targetReadUtilization >= 20 && input.targetReadUtilization <= 90)
    valid_min_write_capacity       = !local.has_min_write_capacity || (input.minProvisionedWriteCapacity >= 1 && input.minProvisionedWriteCapacity <= 40000)
    valid_target_write_utilization = !local.has_target_write_utilization || (input.targetWriteUtilization >= 20 && input.targetWriteUtilization <= 90)
  }

  # Core compliance check: both read and write autoscaling targets must exist.
  enforce {
    condition     = local.has_autoscaling
    error_message = "DynamoDB table '${local.table_name}' uses PROVISIONED billing mode but is missing aws_appautoscaling_target resources for read and/or write capacity. Add aws_appautoscaling_target with scalable_dimension='dynamodb:table:ReadCapacityUnits' and 'dynamodb:table:WriteCapacityUnits', each with resource_id='table/${local.table_name}'."
  }

  enforce {
    condition     = local.valid_min_read_capacity
    error_message = "input.minProvisionedReadCapacity must be between 1 and 40000 when provided. Current value: ${input.minProvisionedReadCapacity}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition     = local.valid_target_read_utilization
    error_message = "input.targetReadUtilization must be between 20 and 90 when provided. Current value: ${input.targetReadUtilization}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition     = local.valid_min_write_capacity
    error_message = "input.minProvisionedWriteCapacity must be between 1 and 40000 when provided. Current value: ${input.minProvisionedWriteCapacity}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition     = local.valid_target_write_utilization
    error_message = "input.targetWriteUtilization must be between 20 and 90 when provided. Current value: ${input.targetWriteUtilization}. Use 0 to leave the parameter unset."
  }
}