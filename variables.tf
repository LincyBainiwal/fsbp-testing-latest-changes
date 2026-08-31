variable "create_failing_resources" {
  description = "When true (default), resources deploy with intentional violations so detection policies fire. Set to false to verify policies produce no false positives."
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

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Availability zones to distribute subnets across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "db_password" {
  description = "Master password for RDS instances."
  type        = string
  sensitive   = true
  default     = "Ch@ngeMe2024!"
}

variable "db_username" {
  description = "Master username for RDS instances."
  type        = string
  default     = "appuser"
}
