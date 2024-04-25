#### EC2 Instance Role
resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name = "EC2_InstanceRoleProfile"
  role = aws_iam_role.ec2_instance_role.id
}

resource "aws_iam_role" "ec2_instance_role" {
  name                  = "EC2_InstanceRole"
  assume_role_policy    = data.aws_iam_policy_document.ec2_instance_role_policy.json
  force_detach_policies = true
  tags                  = var.resource_tags
}

#### ECS Service Role
resource "aws_iam_role" "ecs_service_role" {
  name                  = "ECS_ServiceRole"
  assume_role_policy    = data.aws_iam_policy_document.ecs_service_policy.json
  force_detach_policies = true
  tags                  = var.resource_tags
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ECS_ServiceRolePolicy"
  policy = data.aws_iam_policy_document.ecs_service_role_policy.json
  role   = aws_iam_role.ecs_service_role.id
}

#### ECS Task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name                  = "ECS_TaskExecutionRole"
  assume_role_policy    = data.aws_iam_policy_document.task_assume_role_policy.json
  force_detach_policies = true
  tags                  = var.resource_tags
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "ECS_TaskIAMRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_task_execution_role" {
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.secret_manager_ghcr.json
}

#### ECS Task execution role policy to allow pull from GitHub packages
resource "aws_iam_policy" "ghcr_secret" {
  name        = "secrect_manager"
  description = "Allow access to GitHub packages secrets"
  policy      = data.aws_iam_policy_document.secret_manager_ghcr.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ghcr_secret.arn
}