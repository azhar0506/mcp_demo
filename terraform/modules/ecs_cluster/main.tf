resource "aws_cloudwatch_log_group" "this" {
  name              = "/platform/ecs/${var.environment}-${var.cluster_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = lookup(default_capacity_provider_strategy.value, "base", 0)
    }
  }
}

# Task execution role — used by ECS agent to pull images and write logs
resource "aws_iam_role" "task_execution" {
  name = "${var.environment}-${var.cluster_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: allow task execution role to read SSM secrets
resource "aws_iam_role_policy" "task_execution_ssm" {
  count = var.enable_ssm_access ? 1 : 0
  name  = "ssm-read-access"
  role  = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "secretsmanager:GetSecretValue"
      ]
      Resource = "arn:aws:ssm:*:*:parameter/${var.environment}/${var.cluster_name}/*"
    }]
  })
}
