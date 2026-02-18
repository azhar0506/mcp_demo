# Example: Spinning up a full dev environment
# Uses the platform team's standard modules for VPC, ECS, and S3.
# Copy this and adjust variable values for your team.

module "vpc" {
  source = "../../modules/vpc_standard"

  name               = "main"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  az_count           = 2
  enable_nat_gateway = true
  single_nat_gateway = true # single NAT is fine for dev, saves cost

  tags = {
    Team    = "backend"
    Project = "payments-api"
  }
}

module "ecs" {
  source = "../../modules/ecs_cluster"

  cluster_name = "payments"
  environment  = "dev"

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # In dev, use Fargate Spot to save cost
  default_capacity_provider_strategy = [
    { capacity_provider = "FARGATE_SPOT", weight = 1, base = 1 }
  ]

  enable_container_insights = false # disable in dev to save cost
  log_retention_days        = 7
  enable_ssm_access         = true

  tags = {
    Team    = "backend"
    Project = "payments-api"
  }
}

module "app_storage" {
  source = "../../modules/s3_standard"

  bucket_name       = "app-storage"
  environment       = "dev"
  team              = "backend"
  enable_versioning = false # versioning optional in dev

  tags = {
    Project = "payments-api"
  }
}
