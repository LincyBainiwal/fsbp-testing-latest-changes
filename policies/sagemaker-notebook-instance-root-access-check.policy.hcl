# Copyright IBM Corp. 2026

# Users should not have root access to SageMaker notebook instances

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "sagemaker-notebook-instance-root-access-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_sagemaker_notebook_instance" "root_access_disabled" {
    enforcement_level = input.sagemaker-notebook-instance-root-access-check-enforcement-level
    enforce {
        condition = core::try(attrs.root_access, "Enabled") == "Disabled"
        error_message = "SageMaker notebook instance has root access enabled. Set 'root_access = \"Disabled\"' to restrict root access and follow the principle of least privilege"
    }
}
