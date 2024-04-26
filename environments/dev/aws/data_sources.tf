## VPC
data "aws_availability_zones" "available" {
  state = "available"
}
## ECS AutoScale and Provider
data "aws_ami" "amazon_linux_2_x86_64" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    # Image on arm use amzn2-ami-ecs-hvm-*-arm64-ebs
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"] # Amazon ECS-optimized Amazon Linux 2 AMI
  }
  owners = ["amazon"]
}

data "template_file" "user_data" {
  template = file("./user_data.sh")
  vars = {
    ecs_cluster_name = aws_ecs_cluster.nowhere_ecs.name
  }
}

## Secret Manager
data "aws_secretsmanager_secret" "auth_server_private_key" {
  name = var.auth_server_private_key
}
data "aws_secretsmanager_secret_version" "auth_server_private_key" {
  secret_id = data.aws_secretsmanager_secret.auth_server_private_key.id
}
data "aws_secretsmanager_secret" "auth_server_public_key" {
  name = var.auth_server_public_key
}
data "aws_secretsmanager_secret_version" "auth_server_public_key" {
  secret_id = data.aws_secretsmanager_secret.auth_server_public_key.id
}
data "aws_secretsmanager_secret" "auth_server_github_client" {
  name = var.auth_server_github_secret
}
data "aws_secretsmanager_secret_version" "auth_server_github_client" {
  secret_id = data.aws_secretsmanager_secret.auth_server_github_client.id
}
data "aws_secretsmanager_secret" "auth_server_google_client" {
  name = var.auth_server_google_secret
}
data "aws_secretsmanager_secret_version" "auth_server_google_client" {
  secret_id = data.aws_secretsmanager_secret.auth_server_google_client.id
}
data "aws_secretsmanager_secret" "github_packages_credentials" {
  name = var.github_packages_credentials
}

## IAM Roles
data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "secretsmanager.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "secret_manager_ghcr" {
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      data.aws_secretsmanager_secret.github_packages_credentials.arn
    ]
  }
}
data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutSubscriptionFilter",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}