# Copyright IBM Corp. 2026

# Connections to Amazon Redshift clusters should be encrypted in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "redshift-require-tls-ssl-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
  all_parameter_groups = core::getresources("aws_redshift_parameter_group", {})
}

resource_policy "aws_redshift_cluster" "encryption_in_transit_required" {
  enforcement_level = input.redshift-require-tls-ssl-enforcement-level
  locals {
    # Get the parameter group name (custom or default)
    param_group_name = core::try(attrs.cluster_parameter_group_name, "default.redshift-1.0")
    
    # Check if using default parameter group
    is_default_param_group = local.param_group_name == "default.redshift-1.0"
    
    # Find matching custom parameter group
    matching_param_groups = [
      for pg in local.all_parameter_groups :
      pg if pg.name == local.param_group_name
    ]
    
    has_custom_param_group = core::length(local.matching_param_groups) > 0
    
    # Check require_ssl parameter in custom parameter group
    require_ssl_count = local.has_custom_param_group ? core::length([
      for pg in local.matching_param_groups :
      pg if core::length([
        for param in core::try(pg.parameter, []) :
        param if param.name == "require_ssl" && param.value == "true"
      ]) > 0
    ]) : 0
    
    require_ssl_enabled = local.require_ssl_count > 0
  }

  # Enforce: Cluster must use a custom parameter group with require_ssl = true
  enforce {
    condition = !local.is_default_param_group && local.require_ssl_enabled
    error_message = "Redshift cluster must use a custom parameter group with require_ssl parameter set to 'true' to encrypt connections in transit. Current parameter group: '${local.param_group_name}'"
  }
}
