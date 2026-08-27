# Copyright IBM Corp. 2026

# EC2 instances should use Instance Metadata Service Version 2 (IMDSv2)

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.43.0, < 7.0.0"
    }
  }
}

input "ec2-imdsv2-check-enforcement-level" {
  type = string
  default = "advisory"
}

# Enforce IMDSv2 on individual aws_instance resources.
# The account-level aws_ec2_instance_metadata_defaults resource is NOT
# sufficient — per-instance metadata_options override account defaults
# at launch time (checklist #6: correct resource scope).
resource_policy "aws_instance" "imds_v2_required" {
  enforcement_level = input.ec2-imdsv2-check-enforcement-level
  locals {
    # Default to "optional" (non-compliant) when metadata_options is absent
    # so that instances without an explicit setting fail closed.
    http_tokens = core::try(attrs.metadata_options[0].http_tokens, "optional")
  }

  enforce {
    condition     = local.http_tokens == "required"
    error_message = "EC2 instance must set metadata_options.http_tokens = \"required\" to enforce IMDSv2. Got '${local.http_tokens}'. Set metadata_options { http_tokens = \"required\" } on the aws_instance resource."
  }
}

# Also enforce on aws_launch_template — instances launched from a template
# inherit its metadata_options, so the template must also require IMDSv2.
resource_policy "aws_launch_template" "imds_v2_required" {
  enforcement_level = input.ec2-imdsv2-check-enforcement-level
  locals {
    http_tokens = core::try(attrs.metadata_options[0].http_tokens, "optional")
  }

  enforce {
    condition     = local.http_tokens == "required"
    error_message = "Launch template must set metadata_options.http_tokens = \"required\" to enforce IMDSv2. Got '${local.http_tokens}'. Set metadata_options { http_tokens = \"required\" } on the aws_launch_template resource."
  }
}