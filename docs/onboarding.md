# Platform Engineering — Developer Onboarding Guide

Welcome! This guide explains how to provision infrastructure using the platform team's standard Terraform modules.
If you get stuck, ask in **#platform-help** on Slack before raising a ticket.

---

## Modules Available

| Module | What it creates | Owned by |
|---|---|---|
| `vpc_standard` | VPC, subnets, NAT gateways, route tables | Platform |
| `ecs_cluster` | ECS cluster, Fargate capacity providers, task execution role | Platform |
| `s3_standard` | S3 bucket with encryption, versioning, lifecycle | Platform |

---

## Getting Started

### 1. Prerequisites

- AWS CLI configured with your team's SSO profile
- Terraform >= 1.5 installed (`brew install terraform`)
- Access to the `terraform-state` S3 bucket (request via #platform-help if missing)

### 2. Copy an Example

The fastest way to get started is to copy one of the examples in `terraform/examples/`:

```bash
cp -r terraform/examples/dev_environment terraform/environments/myteam-dev
cd terraform/environments/myteam-dev
```

### 3. Configure Your Backend

Add a `backend.tf` file to store state remotely:

```hcl
terraform {
  backend "s3" {
    bucket         = "platform-terraform-state"
    key            = "myteam/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "platform-terraform-locks"
  }
}
```

> **Note:** The bucket and DynamoDB table already exist. Use a unique `key` path for your team.

### 4. Adjust Variables

Edit `main.tf` and update:
- `environment` — use `dev` for dev environments
- `team` — your team slug (e.g. `backend`, `data`, `frontend`)
- Resource sizing — see module docs for recommended values per environment

### 5. Apply

```bash
terraform init
terraform plan   # review changes
terraform apply
```

---

## Naming Conventions

Resources are named automatically by the modules using the pattern:

```
{environment}-{resource_name}-{team}
```

For example, with `environment = "dev"`, `bucket_name = "uploads"`, `team = "backend"`:

```
dev-uploads-backend
```

**Do not** override names manually — it breaks tagging and cost allocation.

---

## Environments

| Environment | AWS Account | Purpose |
|---|---|---|
| `dev` | `123456789012` | Personal/team dev work |
| `staging` | `234567890123` | Pre-production testing |
| `prod` | `345678901234` | Production (requires PR + approval) |

Prod changes require a PR reviewed by at least one platform team member.

---

## Cost Guidelines

| Resource | Dev recommendation | Prod recommendation |
|---|---|---|
| NAT Gateway | `single_nat_gateway = true` | One per AZ |
| ECS capacity | Fargate Spot only | Fargate + Fargate Spot mixed |
| Container Insights | `enable_container_insights = false` | `true` |
| S3 versioning | Optional | Required |
| Log retention | 7 days | 90 days |

---

## Common Issues

**`Error: Invalid provider configuration`**
- Make sure you're authenticated: `aws sso login --profile myteam-dev`

**`Error: S3 bucket already exists`**
- Bucket names are global. Check if another team is using the same name.

**`Error: InvalidParameterException: The specified capacity provider does not exist`**
- Only `FARGATE` and `FARGATE_SPOT` are supported. EC2-backed capacity requires a platform ticket.

---

## Getting Help

1. Check this guide and the module variable descriptions (they have detailed explanations)
2. Ask in **#platform-help** on Slack
3. Raise a ticket only if Slack hasn't resolved it within 24h
