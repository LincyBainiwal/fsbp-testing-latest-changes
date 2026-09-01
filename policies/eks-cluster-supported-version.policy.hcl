# Copyright IBM Corp. 2026

# EKS clusters should run on a supported Kubernetes version

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-cluster-supported-version-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_eks_cluster" "supported_version" {
    enforcement_level = input.eks-cluster-supported-version-enforcement-level
    locals {
        # NOTE: Update this value whenever AWS raises the EKS supported version floor.
        oldest_version_supported = "1.33"

        # Default to "" (not to a passing version) so a missing version attribute fails
        version     = core::try(attrs.version, "")
        has_version = local.version != ""

        # Only compare semver when a version is present; missing version is non-compliant.
        version_is_compliant = local.has_version ? core::semverconstraint(local.version, ">=${local.oldest_version_supported}") : false
    }

    # Enforce 1: version attribute must be explicitly set.
    enforce {
        condition     = local.has_version
        error_message = "EKS cluster is missing required 'version' attribute. The cluster must explicitly specify a supported Kubernetes version (minimum '${local.oldest_version_supported}')."
    }

    # Enforce 2: provided version must meet the minimum supported version.
    enforce {
        condition     = !local.has_version || local.version_is_compliant
        error_message = "EKS cluster is running an unsupported Kubernetes version '${local.version}'. The cluster must be running at least version '${local.oldest_version_supported}'."
    }
}
