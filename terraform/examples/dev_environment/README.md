# Dev Environment

This Terraform configuration spins up a full dev environment using the platform team's standard modules. It provisions a VPC, an ECS cluster, and S3 buckets for the `backend` team.

## Resources

### VPC (`vpc_standard`)

Creates a standard VPC named `main` with the CIDR block `10.0.0.0/16` spread across 2 availability zones. A single NAT gateway is enabled to allow outbound internet access from private subnets — a single NAT is sufficient for dev and keeps costs low.

### ECS Cluster (`ecs_cluster`)

Creates a Fargate-based ECS cluster named `payments`. In dev, tasks run on **Fargate Spot** to reduce compute costs. Container insights and extended log retention are disabled (logs are kept for 7 days). SSM access is enabled for debugging into running containers.

### S3 Buckets (`s3_standard`)

Two S3 buckets are provisioned:

- **`app-storage`** (`dev-app-storage-backend`) — General application storage for the payments API. Versioning is disabled in dev.
- **`user-uploads`** (`dev-user-uploads-backend`) — Stores user-uploaded files. Versioning is disabled in dev.

Both buckets use the default SSE-S3 (AES256) encryption since no KMS key is provided.

## Bucket Naming Convention

Buckets follow the pattern: `{environment}-{bucket_name}-{team}`

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- This configuration is intended for **dev only**. For staging and prod, versioning should be enabled on S3 buckets and a KMS key should be provided for encryption.
- The single NAT gateway configuration is a cost-saving measure and should not be used in prod (use one NAT per AZ for high availability).
- Fargate Spot instances can be reclaimed by AWS with short notice — do not use in prod for critical workloads.
