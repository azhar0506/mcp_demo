variable "cluster_name" {
  description = "Name of the ECS cluster. Will be prefixed with environment: {environment}-{cluster_name}"
  type        = string
}

variable "environment" {
  description = "Deployment environment. Must be one of: dev, staging, prod"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "capacity_providers" {
  description = <<-EOT
    List of capacity providers to associate with the cluster.
    Use FARGATE and FARGATE_SPOT for serverless. For EC2-backed tasks, raise a ticket with the platform team.
    Recommended: ["FARGATE", "FARGATE_SPOT"]
  EOT
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = <<-EOT
    Default capacity provider strategy for tasks that don't specify one.
    Example (split 80% Fargate / 20% Spot):
    [
      { capacity_provider = "FARGATE",      weight = 8, base = 1 },
      { capacity_provider = "FARGATE_SPOT", weight = 2 }
    ]
  EOT
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = [
    { capacity_provider = "FARGATE",      weight = 1, base = 1 },
    { capacity_provider = "FARGATE_SPOT", weight = 0 }
  ]
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster. Recommended for staging and prod."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain ECS container logs in CloudWatch. Use 7 for dev, 90 for prod."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 180, 365], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch retention period."
  }
}

variable "enable_ssm_access" {
  description = "Grant the task execution role permission to read SSM Parameter Store secrets under /{environment}/{cluster_name}/*"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
