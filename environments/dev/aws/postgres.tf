resource "aws_db_instance" "postgres" {
  allocated_storage      = 5
  max_allocated_storage  = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "14"
  multi_az               = true
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 5432
  parameter_group_name   = aws_db_parameter_group.group.name
  vpc_security_group_ids = [aws_security_group.rds_postgres.id, aws_security_group.ecs_ec2.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  skip_final_snapshot    = true
  tags                   = var.resource_tags
}

# Designates a collection of subnets that your RDS instance can be provisioned in
resource "aws_db_subnet_group" "postgres" {
  name       = "postgres-maz-sg-${var.env}"
  subnet_ids = aws_subnet.private[*].id
  tags       = var.resource_tags
}

# Parameter group acts as a container for the engine configuration values that can be applied to one or more DB instances
resource "aws_db_parameter_group" "group" {
  name        = "postgres14-pg-${var.env}"
  family      = "postgres14"
  description = "parameter group for nowhere-postgres"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = var.resource_tags
}