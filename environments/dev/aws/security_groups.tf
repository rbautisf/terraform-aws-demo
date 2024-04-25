resource "aws_security_group" "ecs_ec2" {
  name        = "ecs-ec2-sg${var.env}"
  description = "Security group for the ECS EC2 instances"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP on ephemeral ports"
    from_port       = 1024
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Allow SSH ingress traffic from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host.id]
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}

resource "aws_security_group" "rds_postgres" {
  name        = "rds-postgres-sg${var.env}"
  description = "Security group for PostgreSQL"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.main_vpc.cidr_block]
    security_groups = [aws_security_group.ecs_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}

resource "aws_security_group" "elasticache_redis" {
  name        = "redis-sg${var.env}"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.main_vpc.cidr_block]
    security_groups = [aws_security_group.ecs_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #
  tags = var.resource_tags
}

resource "aws_security_group" "alb" {
  name        = "alb_sg_${var.env}"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main_vpc.id

  # allow ingress from the internet gateway on port 80
  ingress {
    description = "Allow all ingress traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}

resource "aws_security_group" "bastion_host" {
  name        = "bastion-host_sg_${var.env}"
  description = "Bastion host Security Group"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH access from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ## The IP range could be limited to the developers IP addresses if they are fix
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}