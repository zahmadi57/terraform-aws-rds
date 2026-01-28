variable "identifier" {
  description = "DB instance identifier"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

# Optional per your requirements
variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "vpc_id" {
  description = "VPC to deploy into"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (recommend private subnets in >=2 AZs)"
  type        = list(string)
}

# Password handling (sandbox-safe)
# If you do NOT set password, module generates one via random_password.
variable "password" {
  description = "Master password (optional). If null, one is generated."
  type        = string
  default     = null
  sensitive   = true
}

# Optional safety/ops knobs (not required by your spec, but useful and safe)
variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to reach MySQL port 3306 (leave empty for no inbound)"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach MySQL port 3306 (leave empty for no inbound)"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "publicly_accessible" {
  description = "Whether the DB is publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention days (0 disables backups; sandbox-friendly)"
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy (sandbox-friendly)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Protect DB from deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
