# Copyright IBM Corp. 2026

# RDS DB instances should not be deployed in public subnets with routes to internet gateways

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "rds-instance-subnet-igw-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_db_instance" "no_public_subnet_igw" {
  enforcement_level = input.rds-instance-subnet-igw-check-enforcement-level
  locals {
    # Get the subnet group name - when unset, it will be null/empty
    # AWS will use the default subnet group at apply time, but we cannot evaluate that here
    subnet_group_name = core::try(attrs.db_subnet_group_name, "")
    
    # Get all DB subnet groups and filter by name
    all_db_subnet_groups = core::getresources("aws_db_subnet_group", {})
    db_subnet_groups = local.subnet_group_name != "" ? [
      for sg in local.all_db_subnet_groups :
      sg if core::try(sg.name, "") == local.subnet_group_name
    ] : []
    
    # Extract subnet IDs from the matching subnet group
    db_subnet_group = core::length(local.db_subnet_groups) > 0 ? local.db_subnet_groups[0] : null
    subnet_ids = core::try(local.db_subnet_group.subnet_ids, [])
    
    # Fail closed if subnet topology cannot be resolved from Terraform resources
    # When db_subnet_group_name is unset (null/empty), we cannot evaluate subnet topology
    # When db_subnet_group_name is set but not found, we also cannot evaluate
    # This prevents false negatives when subnet groups are external, unmanaged, or AWS-default
    can_evaluate = local.subnet_group_name != "" && core::length(local.subnet_ids) > 0
    
    # Get all subnets to resolve VPC IDs for main route table lookup
    rds_igw_all_subnets = core::getresources("aws_subnet", {})
    db_subnets = [
      for s in local.rds_igw_all_subnets :
      s if core::contains(local.subnet_ids, core::try(s.id, ""))
    ]
    
    # Get all explicit route table associations
    all_associations = core::getresources("aws_route_table_association", {})
    explicit_associations = [
      for assoc in local.all_associations :
      assoc if core::contains(local.subnet_ids, core::try(assoc.subnet_id, ""))
    ]
    
    # Find explicitly associated route table IDs
    explicit_route_table_ids = [
      for assoc in local.explicit_associations :
      core::try(assoc.route_table_id, "")
      if core::try(assoc.route_table_id, "") != ""
    ]
    
    # Get all main route table associations to handle subnets without explicit associations
    all_main_associations = core::getresources("aws_main_route_table_association", {})
    
    # For subnets without explicit association, resolve the VPC main route table
    implicit_main_route_table_ids = [
      for subnet in local.db_subnets :
      core::try([
        for main_assoc in local.all_main_associations :
        core::try(main_assoc.route_table_id, "")
        if core::try(main_assoc.vpc_id, "") == core::try(subnet.vpc_id, "")
      ][0], "")
      if core::length([
        for assoc in local.explicit_associations :
        assoc if core::try(assoc.subnet_id, "") == core::try(subnet.id, "")
      ]) == 0
    ]
    
    # Combine explicit and implicit (main) route table IDs
    effective_route_table_ids = core::distinct(core::concat(
      local.explicit_route_table_ids,
      local.implicit_main_route_table_ids
    ))
    
    # Get all route tables in the environment
    all_route_tables = core::getresources("aws_route_table", {})
    
    # Find route tables that have routes to Internet Gateways with default routes
    # Check for IGW prefix more robustly and ensure it's a default route
    route_tables_with_igw = [
      for rt in local.all_route_tables :
      rt if (
        core::contains(local.effective_route_table_ids, core::try(rt.id, "")) &&
        core::length([
          for route in core::try(rt.route, []) :
          route if (
            (core::try(route.cidr_block, "") == "0.0.0.0/0" || core::try(route.ipv6_cidr_block, "") == "::/0") &&
            core::length(core::regexall("^igw-", core::try(route.gateway_id, ""))) > 0
          )
        ]) > 0
      )
    ]
    
    # Check if any of the DB subnets have routes to internet gateways
    has_igw_route = core::length(local.route_tables_with_igw) > 0
  }
  
  enforce {
    # Fail closed: if subnet group cannot be resolved, treat as noncompliant
    condition = local.can_evaluate && !local.has_igw_route
    error_message = "RDS DB instance must use a resolvable DB subnet group whose subnets do not have default routes to an Internet Gateway. Unresolved subnet groups and public subnet routing are noncompliant"
  }
}
