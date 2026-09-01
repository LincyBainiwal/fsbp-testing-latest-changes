# Copyright IBM Corp. 2026

# Route 53 public hosted zones should log DNS queries

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "route53-query-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    all_query_logs = core::getresources("aws_route53_query_log", {})
    query_log_map = {
        for log in local.all_query_logs :
        log.zone_id => log
    }
}

resource_policy "aws_route53_zone" "dns_query_logging_enabled" {
    enforcement_level = input.route53-query-logging-enabled-enforcement-level
    # Only check public hosted zones (private zones have vpc blocks)
    filter = core::try(core::length(attrs.vpc), 0) == 0

    locals {
        zone_name = core::try(attrs.name, attrs.zone_id)

        # Check a matching aws_route53_query_log resource exists for this zone
        matching_log = core::try(local.query_log_map[attrs.zone_id], null)
        has_query_logging = local.matching_log != null

        log_destination_arn = local.has_query_logging ? core::try(local.matching_log.cloudwatch_log_group_arn, "") : ""
        has_valid_destination = local.log_destination_arn != ""
    }

    # Check 1: a query log resource must exist for this zone
    enforce {
        condition     = local.has_query_logging
        error_message = "Route 53 public hosted zone '${local.zone_name}' must have DNS query logging enabled. Create an aws_route53_query_log resource with zone_id = \"${attrs.zone_id}\"."
    }

    # Check 2: the matched query log resource must have a valid CloudWatch log group ARN
    enforce {
        condition     = !local.has_query_logging || local.has_valid_destination
        error_message = "Route 53 public hosted zone '${local.zone_name}' has an aws_route53_query_log resource but its cloudwatch_log_group_arn is empty. Set cloudwatch_log_group_arn to a valid CloudWatch Logs ARN."
    }
}