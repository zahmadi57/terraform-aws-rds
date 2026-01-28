resource "random_password" "master" {
  length  = 20
  special = true
}

locals {
  # Use provided password if user supplies one; otherwise generate.     (ternary operator)
  master_password = var.password != null ? var.password : random_password.master.result
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(sensitive({}), var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.identifier}-db-sg"
  description = "Security group for RDS MySQL: ${var.identifier}"
  vpc_id      = var.vpc_id

  # Sandbox-safe default: no inbound unless you explicitly allow it via variables below.
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "MySQL from allowed CIDRs"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "MySQL from allowed security groups"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-db-sg"
  })
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = "mysql"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.username
  password = local.master_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  publicly_accessible = var.publicly_accessible

  # Sandbox-friendly defaults
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = true

  tags = merge(var.tags, {
    Name = var.identifier
  })
}
