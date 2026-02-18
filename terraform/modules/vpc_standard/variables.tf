variable "name" {
  description = "Name identifier for the VPC and related resources (e.g. 'main', 'shared')"
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

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Recommended ranges: dev=10.0.0.0/16, staging=10.1.0.0/16, prod=10.2.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to deploy into. Must be between 2 and 3. Use 3 for prod."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3"
  }
}

variable "enable_nat_gateway" {
  description = "Whether to provision NAT Gateways for private subnet egress. Set to false for dev to save cost."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ. Saves cost in non-prod but reduces HA."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
