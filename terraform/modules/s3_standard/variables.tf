variable "bucket_name" {
  description = "Short name for the bucket. Will be combined with environment and team to form the full bucket name: {environment}-{bucket_name}-{team}"
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

variable "team" {
  description = "Owning team slug (e.g. platform, data, backend). Used in bucket naming and tags."
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 versioning. Required for prod buckets. Defaults to true."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of a KMS key to use for SSE-KMS encryption. If null, SSE-S3 (AES256) is used."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Optional list of lifecycle rules to apply to the bucket."
  type = list(object({
    id                                  = string
    enabled                             = bool
    expiration_days                     = number
    noncurrent_version_expiration_days  = number
  }))
  default = null
}

variable "tags" {
  description = "Additional tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
