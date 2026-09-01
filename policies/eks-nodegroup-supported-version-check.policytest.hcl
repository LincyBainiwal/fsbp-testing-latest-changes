# Copyright IBM Corp. 2026

policytest {
    targets = [
        "eks-nodegroup-supported-version-check.policy.hcl"
    ]
}

# ---------------------------------------------------------------------------
# PASS cases
# ---------------------------------------------------------------------------

# Test 1: PASS - Node group with exactly the minimum supported version
resource "aws_eks_node_group" "pass_ng_min_version" {
    attrs = {
        cluster_name    = "example-cluster"
        node_group_name = "ng-min"
        node_role_arn   = "arn:aws:iam::123456789012:role/eks-node-role"
        version         = "1.33"
    }
}

# Test 2: PASS - Node group with a newer supported version
resource "aws_eks_node_group" "pass_ng_newer_version" {
    attrs = {
        cluster_name    = "example-cluster"
        node_group_name = "ng-newer"
        node_role_arn   = "arn:aws:iam::123456789012:role/eks-node-role"
        version         = "1.34"
    }
}

# ---------------------------------------------------------------------------
# FAIL cases
# ---------------------------------------------------------------------------

# Test 3: FAIL - Reads attrs.version directly and correctly fails it.
resource "aws_eks_node_group" "fail_ng_unsupported_version" {
    expect_failure = true
    attrs = {
        cluster_name    = "example-cluster"
        node_group_name = "ng-old"
        node_role_arn   = "arn:aws:iam::123456789012:role/eks-node-role"
        version         = "1.30"
    }
}

# Test 4: FAIL - Node group with version one below minimum (boundary)
resource "aws_eks_node_group" "fail_ng_just_below_min" {
    expect_failure = true
    attrs = {
        cluster_name    = "example-cluster"
        node_group_name = "ng-boundary"
        node_role_arn   = "arn:aws:iam::123456789012:role/eks-node-role"
        version         = "1.32"
    }
}

# Test 5: FAIL - Node group with no version attribute set.
resource "aws_eks_node_group" "fail_ng_no_version" {
    expect_failure = true
    attrs = {
        cluster_name    = "example-cluster"
        node_group_name = "ng-no-version"
        node_role_arn   = "arn:aws:iam::123456789012:role/eks-node-role"
    }
}

# Test 6: FAIL - Node group with old version even though cluster has a compliant version.
resource "aws_eks_node_group" "fail_ng_old_version_compliant_cluster" {
    expect_failure = true
    attrs = {
        cluster_name    = "compliant-cluster"
        node_group_name = "ng-stale"
        node_role_arn   = "arn:aws:iam::123456789012:role/eks-node-role"
        version         = "1.28"
    }
}

resource "aws_eks_cluster" "compliant_cluster" {
    skip = true
    attrs = {
        name    = "compliant-cluster"
        version = "1.33"
    }
}
