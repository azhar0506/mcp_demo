# Platform Engineering — Runbook

Operational runbook for common platform tasks. For general onboarding, see `onboarding.md`.

---

## ECS

### Switching Between Fargate and Fargate Spot

Update `default_capacity_provider_strategy` in your `ecs_cluster` module call and apply.
No downtime — existing running tasks are unaffected. New tasks pick up the new strategy.

```hcl
# Prod: base on Fargate, overflow to Spot
default_capacity_provider_strategy = [
  { capacity_provider = "FARGATE",      weight = 8, base = 1 },
  { capacity_provider = "FARGATE_SPOT", weight = 2 }
]
```

---

### Enabling SSM Secrets Access

Set `enable_ssm_access = true` in the `ecs_cluster` module. This grants the task execution role
read access to secrets under `/{environment}/{cluster_name}/*` in SSM Parameter Store.

Then in your task definition, reference secrets like:

```json
"secrets": [
  {
    "name": "DB_PASSWORD",
    "valueFrom": "arn:aws:ssm:eu-west-1:123456789012:parameter/dev/payments/db-password"
  }
]
```

---

### Viewing Container Logs

Logs are sent to CloudWatch automatically. The log group name is an output of the `ecs_cluster` module:

```bash
# Tail logs for a service
aws logs tail /platform/ecs/dev-payments --follow --profile myteam-dev
```

---

### An ECS Task is Stuck in PENDING

```bash
# Describe the service to see recent events
aws ecs describe-services \
  --cluster dev-payments \
  --services my-service \
  --profile myteam-dev \
  --query 'services[0].events[:5]'
```

Common causes:
- **No capacity** — Fargate Spot interrupted; add `FARGATE` as a fallback in your strategy
- **Image pull failure** — check ECR permissions on the task execution role
- **Secrets error** — verify SSM path matches `/{environment}/{cluster_name}/*` and `enable_ssm_access = true`

---

## S3

### Enabling Versioning on an Existing Bucket

Set `enable_versioning = true` and apply. This is non-destructive — existing objects are unaffected.

> Note: Once versioning is enabled, it cannot be fully disabled, only suspended.

---

### Adding a Lifecycle Rule

Add to your `s3_standard` module:

```hcl
lifecycle_rules = [
  {
    id                                 = "expire-old-logs"
    enabled                            = true
    expiration_days                    = 90
    noncurrent_version_expiration_days = 30
  }
]
```

---

### Cross-Account Bucket Access

Not supported via the standard module. Raise a ticket with:
- Source account ID
- Target account ID
- Required actions (e.g. `s3:GetObject`, `s3:PutObject`)

---

## VPC

### Adding Subnets to an Existing VPC

The `vpc_standard` module does not support adding subnets post-creation without recreating the VPC.
If you need additional subnets, raise a ticket — the platform team will handle this manually.

---

### Peering VPCs

VPC peering is managed centrally by the platform team. Raise a ticket with:
- Source VPC name and environment
- Target VPC name and environment
- CIDR ranges (no overlap allowed)

---

## Incident Response

### An ECS Service Has 0 Running Tasks

```bash
# Check service status and events
aws ecs describe-services \
  --cluster dev-payments \
  --services my-service \
  --profile myteam-dev

# Check stopped task errors
aws ecs list-tasks \
  --cluster dev-payments \
  --desired-status STOPPED \
  --profile myteam-dev

aws ecs describe-tasks \
  --cluster dev-payments \
  --tasks <task-id> \
  --profile myteam-dev \
  --query 'tasks[0].stoppedReason'
```

---

### Terraform State Lock Stuck

If apply was interrupted and the state is locked:

```bash
terraform force-unlock <lock-id>
```

Get the lock ID from the error message. If unsure, raise a ticket — do not force unlock without understanding why it's locked.

---

## Escalation

If something isn't covered here, escalate in this order:
1. **#platform-help** Slack channel (response within 2h during business hours)
2. **PagerDuty** — for production incidents only
3. **Jira ticket** — for non-urgent requests (SLA: 3 business days)
