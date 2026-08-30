variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "create_failing_resources" {
  description = "When true (default), fail resources deploy with intentional violations so detection policies fire. Set to false to verify policies produce no false positives against compliant configuration."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to every taggable resource in this configuration."
  type        = map(string)
  default = {
    Project   = "security-policy-regression"
    ManagedBy = "terraform"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the shared VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per availability zone."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to distribute subnets across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key for DynamoDB table and DAX cluster encryption. Set this in the HCP Terraform workspace variables."
  type        = string
}
