output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Full name of the ECS cluster (including environment prefix)"
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "task_execution_role_arn" {
  description = "ARN of the task execution IAM role. Pass this as execution_role_arn in your ECS task definitions."
  value       = aws_iam_role.task_execution.arn
}

output "task_execution_role_name" {
  description = "Name of the task execution IAM role"
  value       = aws_iam_role.task_execution.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for this cluster. Use this as the awslogs-group in your task definitions."
  value       = aws_cloudwatch_log_group.this.name
}
