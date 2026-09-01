# Copyright IBM Corp. 2026

policytest {
    targets = [
        "eks-cluster-supported-version.policy.hcl"
    ]
}

# Test 1: PASS - EKS cluster with minimum supported version exactly
resource "aws_eks_cluster" "pass_supported_version" {
    attrs = {
        name     = "example-cluster"
        version  = "1.33"
        role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
        vpc_config = [{
            subnet_ids = ["subnet-12345", "subnet-67890"]
        }]
    }
}

# Test 2: PASS - EKS cluster with a newer supported version
resource "aws_eks_cluster" "pass_newer_version" {
    attrs = {
        name     = "example-cluster"
        version  = "1.34"
        role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
        vpc_config = [{
            subnet_ids = ["subnet-12345", "subnet-67890"]
        }]
    }
}

# Test 3: FAIL - EKS cluster with unsupported (too old) version
resource "aws_eks_cluster" "fail_unsupported_version" {
    expect_failure = true
    attrs = {
        name     = "example-cluster"
        version  = "1.30"
        role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
        vpc_config = [{
            subnet_ids = ["subnet-12345", "subnet-67890"]
        }]
    }
}

# Test 4: FAIL - EKS cluster with version one below minimum (boundary)
resource "aws_eks_cluster" "fail_version_just_below_min" {
    expect_failure = true
    attrs = {
        name     = "example-cluster"
        version  = "1.32"
        role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
        vpc_config = [{
            subnet_ids = ["subnet-12345", "subnet-67890"]
        }]
    }
}

# Test 5: FAIL - EKS cluster with no version specified.
resource "aws_eks_cluster" "fail_no_version" {
    expect_failure = true
    attrs = {
        name     = "example-cluster"
        role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
        vpc_config = [{
            subnet_ids = ["subnet-12345", "subnet-67890"]
        }]
    }
}
