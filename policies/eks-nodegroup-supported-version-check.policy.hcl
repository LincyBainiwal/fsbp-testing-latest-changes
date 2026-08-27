# Copyright IBM Corp. 2026

# EKS node groups should run on a supported Kubernetes version

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-nodegroup-supported-version-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_eks_node_group" "supported_ng_version" {
    enforcement_level = input.eks-nodegroup-supported-version-check-enforcement-level
    locals {
        oldest_ng_version_supported = "1.33"

        # Read version directly from the node group resource, not from the cluster.
        version     = core::try(attrs.version, "")
        has_version = local.version != ""

        # Only evaluate semver when a version is present; absence is non-compliant.
        version_is_compliant = local.has_version ? core::semverconstraint(local.version, ">=${local.oldest_ng_version_supported}") : false
    }

    # Enforce 1: version attribute must be explicitly set on the node group.
    enforce {
        condition     = local.has_version
        error_message = "EKS node group is missing required 'version' attribute. The node group must explicitly specify a supported Kubernetes version (minimum '${local.oldest_ng_version_supported}')."
    }

    # Enforce 2: provided version must meet the minimum supported version.
    enforce {
        condition     = !local.has_version || local.version_is_compliant
        error_message = "EKS node group is running an unsupported Kubernetes version '${local.version}'. The node group must be running at least version '${local.oldest_ng_version_supported}'."
    }
}