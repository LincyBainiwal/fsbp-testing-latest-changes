# ---------------------------------------------------------------------------
# main.tf — root module wiring all 54 service modules
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Tier 1 — Foundation (no cross-module inputs)
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "fsbp-testing-latest-changes"
    }
  }
}

# ---------------------------------------------------------------------------
# Networking — VPC + private + public subnets required by EC2/DAX modules
# ---------------------------------------------------------------------------

# resource "aws_vpc" "main" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = merge(var.tags, {
#     Name = "regression-test-vpc"
#   })
# }

# resource "aws_subnet" "private" {
#   count = length(var.availability_zones)

#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.private_subnet_cidrs[count.index]
#   availability_zone = var.availability_zones[count.index]

#   tags = merge(var.tags, {
#     Name = "regression-test-private-${count.index + 1}"
#   })
# }

# resource "aws_subnet" "public" {
#   count = length(var.availability_zones)

#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.public_subnet_cidrs[count.index]
#   availability_zone       = var.availability_zones[count.index]
#   map_public_ip_on_launch = false

#   tags = merge(var.tags, {
#     Name = "regression-test-public-${count.index + 1}"
#   })
# }

# ---------------------------------------------------------------------------
# IAM — EC2 instance profile (inline; no separate IAM module needed)
# ---------------------------------------------------------------------------

# data "aws_iam_policy_document" "ec2_assume_role" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "ec2_instance_role" {
#   name               = "regression-test-ec2-instance-role"
#   assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

#   tags = merge(var.tags, {
#     Name = "regression-test-ec2-instance-role"
#   })
# }

# resource "aws_iam_role_policy_attachment" "ec2_ssm" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ec2" {
#   name = "regression-test-ec2-instance-profile"
#   role = aws_iam_role.ec2_instance_role.name

#   tags = merge(var.tags, {
#     Name = "regression-test-ec2-instance-profile"
#   })
# }

# ---------------------------------------------------------------------------
# KMS — shared CMK (required by IAM + Lambda)
# ---------------------------------------------------------------------------

module "kms" {
  source = "./modules/kms"

  create_failing_resources = var.create_failing_resources
  tags                     = var.tags
}

# ---------------------------------------------------------------------------
# Networking — VPC + private subnets (required by RDS)
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------------

# module "rds" {
#   source = "./modules/rds"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   availability_zones       = var.availability_zones
#   kms_key_arn              = module.kms.shared_key_arn
#   rds_monitoring_role_arn  = aws_iam_role.rds_monitoring.arn
# }
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "regression-test-vpc"
  })
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"][count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "regression-test-private-${count.index + 1}"
  })
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"][count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "regression-test-public-${count.index + 1}"
  })
}

# ---------------------------------------------------------------------------
# IAM — RDS Enhanced Monitoring role (inline)
# ---------------------------------------------------------------------------

# data "aws_iam_policy_document" "rds_monitoring_assume" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["monitoring.rds.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "rds_monitoring" {
#   name               = "regression-test-rds-monitoring-role"
#   assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume.json

#   tags = merge(var.tags, {
#     Name = "regression-test-rds-monitoring-role"
#   })
# }

# resource "aws_iam_role_policy_attachment" "rds_monitoring" {
#   role       = aws_iam_role.rds_monitoring.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
# }

# ---------------------------------------------------------------------------
# IAM — EKS cluster role + node role (inline)
# ---------------------------------------------------------------------------

# data "aws_iam_policy_document" "eks_cluster_assume" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "eks_cluster" {
#   name               = "regression-test-eks-cluster-role"
#   assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json

#   tags = merge(var.tags, {
#     Name = "regression-test-eks-cluster-role"
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#   role       = aws_iam_role.eks_cluster.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }

# data "aws_iam_policy_document" "eks_node_assume" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "eks_node" {
#   name               = "regression-test-eks-node-role"
#   assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json

#   tags = merge(var.tags, {
#     Name = "regression-test-eks-node-role"
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_node_policy" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# ---------------------------------------------------------------------------
# EKS
# ---------------------------------------------------------------------------

# module "eks" {
#   source = "./modules/eks"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   availability_zones       = var.availability_zones
#   kms_key_arn              = module.kms.shared_key_arn
#   eks_cluster_role_arn     = aws_iam_role.eks_cluster.arn
#   eks_node_role_arn        = aws_iam_role.eks_node.arn
# }

# ---------------------------------------------------------------------------
# IAM — controls + shared roles (provides lambda_execution_role_arn)
# ---------------------------------------------------------------------------

# module "iam" {
#   source = "./modules/iam"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# ---------------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------------

# module "lambda" {
#   source = "./modules/lambda"

#   create_failing_resources  = var.create_failing_resources
#   tags                      = var.tags
#   vpc_id                    = aws_vpc.main.id
#   private_subnet_ids        = aws_subnet.private[*].id
#   kms_key_arn               = module.kms.shared_key_arn
#   lambda_execution_role_arn = module.iam.lambda_execution_role_arn
# }

# ---------------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------------

# module "rds" {
#   source = "./modules/rds"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   availability_zones       = var.availability_zones
#   kms_key_arn              = module.kms.shared_key_arn
#   rds_monitoring_role_arn  = module.iam.rds_monitoring_role_arn
# }

# module "ec2" {
#   source = "./modules/ec2"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   public_subnet_ids        = aws_subnet.public[*].id
#   availability_zones       = var.availability_zones
#   instance_profile_name    = module.iam.ec2_instance_profile_name
#   kms_key_arn              = module.kms.shared_key_arn
# }

# ---------------------------------------------------------------------------
# CloudTrail
# ---------------------------------------------------------------------------

# module "cloudtrail" {
#   source = "./modules/cloudtrail"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
#   cloudwatch_role_arn      = module.iam.cloudtrail_cloudwatch_role_arn
# }

# ---------------------------------------------------------------------------
# S3 — provides logs_bucket_id for ELB access logs
# ---------------------------------------------------------------------------

module "s3" {
  source = "./modules/s3"

  create_failing_resources = var.create_failing_resources
  tags                     = var.tags
}

# # ---------------------------------------------------------------------------
# # ELB
# # ---------------------------------------------------------------------------

# module "elb" {
#   source = "./modules/elb"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   public_subnet_ids        = aws_subnet.public[*].id
#   private_subnet_ids       = aws_subnet.private[*].id
#   logs_bucket_id           = module.s3.logs_bucket_id
# }

# module "waf" {
#   source = "./modules/waf"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   alb_arn                  = module.elb.alb_arn
#   logs_bucket_arn          = module.s3.logs_bucket_arn
# }

# # ---------------------------------------------------------------------------
# # Inline security group for ECS tasks (module.ec2 not active)
# # ---------------------------------------------------------------------------

# resource "aws_security_group" "app" {
#   name        = "regression-test-app-sg"
#   description = "Application security group for ECS Fargate tasks."
#   vpc_id      = aws_vpc.main.id

#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(var.tags, {
#     Name = "regression-test-app-sg"
#   })
# }

# # ---------------------------------------------------------------------------
# # Tier 4 — ECS (depends on kms + iam + inline sg)
# # ---------------------------------------------------------------------------

# module "ecs" {
#   source = "./modules/ecs"

#   create_failing_resources    = var.create_failing_resources
#   tags                        = var.tags
#   vpc_id                      = aws_vpc.main.id
#   private_subnet_ids          = aws_subnet.private[*].id
#   kms_key_arn                 = module.kms.shared_key_arn
#   ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
#   app_security_group_id       = aws_security_group.app.id
# }

# # ---------------------------------------------------------------------------
# # Tier 5 — Services depending on elb + waf + s3 + kms + iam
# # ---------------------------------------------------------------------------

# module "cloudfront" {
#   source = "./modules/cloudfront"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   logs_bucket_id           = module.s3.logs_bucket_id
#   wafv2_web_acl_arn        = module.waf.wafv2_web_acl_arn
# }

# module "api_gateway" {
#   source = "./modules/api-gateway"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   wafv2_web_acl_arn        = module.waf.wafv2_web_acl_arn
# }

# module "autoscaling_group" {
#   source = "./modules/autoscaling-group"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   public_subnet_ids        = aws_subnet.public[*].id
#   availability_zones       = var.availability_zones
#   kms_key_arn              = module.kms.shared_key_arn
#   target_group_arn         = module.elb.target_group_arn
#   instance_profile_name    = module.iam.ec2_instance_profile_name
# }

# # ---------------------------------------------------------------------------
# # Data services
# # ---------------------------------------------------------------------------

# module "redshift" {
#   source = "./modules/redshift"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "redshift_serverless" {
#   source = "./modules/redshiftserverless"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "dynamo_db" {
#   source = "./modules/dynamo-db"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

module "kinesis" {
  source = "./modules/kinesis"

  create_failing_resources = var.create_failing_resources
  tags                     = var.tags
  kms_key_arn              = module.kms.shared_key_arn
  logs_bucket_id           = module.s3.logs_bucket_id
  logs_bucket_arn          = module.s3.logs_bucket_arn
}

# module "opensearch" {
#   source = "./modules/opensearch"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "elasticsearch" {
#   source = "./modules/elasticsearch"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "msk" {
#   source = "./modules/msk"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "neptune" {
#   source = "./modules/neptune"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "docdb" {
#   source = "./modules/docdb"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "elasticache" {
#   source = "./modules/elasticache"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   private_subnet_cidrs     = var.private_subnet_cidrs
#   kms_key_arn              = module.kms.shared_key_arn
# }

# # ---------------------------------------------------------------------------
# # Messaging + secrets
# # ---------------------------------------------------------------------------

# module "secretsmanager" {
#   source = "./modules/secretsmanager"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "sqs" {
#   source = "./modules/sqs"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "sns" {
#   source = "./modules/sns"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
# }

# # ---------------------------------------------------------------------------
# # Developer / analytics services
# # ---------------------------------------------------------------------------

# module "athena" {
#   source = "./modules/athena"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
#   logs_bucket_id           = module.s3.logs_bucket_id
# }

# module "codebuild" {
#   source = "./modules/codebuild"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
#   logs_bucket_id           = module.s3.logs_bucket_id
#   logs_bucket_arn          = module.s3.logs_bucket_arn
# }

# module "datasync" {
#   source = "./modules/datasync"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   logs_bucket_arn          = module.s3.logs_bucket_arn
# }

# module "glue" {
#   source = "./modules/glue"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
#   logs_bucket_id           = module.s3.logs_bucket_id
# }

# module "emr" {
#   source = "./modules/emr"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
#   logs_bucket_id           = module.s3.logs_bucket_id
# }

# module "sagemaker" {
#   source = "./modules/sagemaker"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   kms_key_arn              = module.kms.shared_key_arn
# }

# # ---------------------------------------------------------------------------
# # Storage
# # ---------------------------------------------------------------------------

# module "backup" {
#   source = "./modules/backup"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "efs" {
#   source = "./modules/efs"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "fsx" {
#   source = "./modules/fsx"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "ecr" {
#   source = "./modules/ecr"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# # ---------------------------------------------------------------------------
# # Orchestration + events
# # ---------------------------------------------------------------------------

# module "stepfunction" {
#   source = "./modules/stepfunction"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "eventbridge" {
#   source = "./modules/eventbridge"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# # ---------------------------------------------------------------------------
# # Network + security services
# # ---------------------------------------------------------------------------

# module "network_firewall" {
#   source = "./modules/network-firewall"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "guardduty" {
#   source = "./modules/guardduty"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "inspector" {
#   source = "./modules/inspector"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "macie" {
#   source = "./modules/macie"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# # ---------------------------------------------------------------------------
# # Application + middleware services
# # ---------------------------------------------------------------------------

# module "appsync" {
#   source = "./modules/appsync"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   kms_key_arn              = module.kms.shared_key_arn
# }

# module "mq" {
#   source = "./modules/mq"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
# }

# module "connect" {
#   source = "./modules/connect"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "dms" {
#   source = "./modules/dms"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
# }

# module "transfer" {
#   source = "./modules/transfer"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
# }

# module "elasticbeanstalk" {
#   source = "./modules/elasticbeanstalk"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   instance_profile_name    = module.iam.ec2_instance_profile_name
# }

# # ---------------------------------------------------------------------------
# # Specialist / global services
# # ---------------------------------------------------------------------------

# module "acm" {
#   source = "./modules/acm"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "route53" {
#   source = "./modules/route53"

#   providers = {
#     aws           = aws
#     aws.us_east_1 = aws.us_east_1
#   }

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "ssm" {
#   source = "./modules/ssm"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "servicecatalog" {
#   source = "./modules/servicecatalog"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
# }

# module "workspaces" {
#   source = "./modules/workspaces"

#   create_failing_resources = var.create_failing_resources
#   tags                     = var.tags
#   vpc_id                   = aws_vpc.main.id
#   private_subnet_ids       = aws_subnet.private[*].id
#   kms_key_arn              = module.kms.shared_key_arn
# }
