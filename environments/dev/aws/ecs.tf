# Creating an ECS cluster
resource "aws_ecs_cluster" "nowhere_ecs" {
  name = "nowhere-ecs-${var.env}"

  lifecycle {
    create_before_destroy = true
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.resource_tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/nowhere_learn"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

# Creating an ECS task definition
resource "aws_ecs_task_definition" "auth_server_task" {
  family             = "service"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_iam_role.arn
  # there is an option with AppMesh Proxy  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#with-appmesh-proxy
  container_definitions = jsonencode([
    {
      name  = "spring-auth-server"
      image = var.auth_server_image
      repositoryCredentials = {
        credentialsParameter = data.aws_secretsmanager_secret.github_packages_credentials.arn
      }
      cpu       = 800
      memory    = 800
      essential = true
      environment = [
        {
          name  = "DATASOURCE_URL"
          value = "jdbc:postgresql://${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
        },
        {
          name  = "DB_USERNAME"
          value = aws_db_instance.postgres.username
        },
        {
          name  = "DB_PASSWORD"
          value = aws_db_instance.postgres.password
        },
        {
          name  = "REDIS_HOST"
          value = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
        },

        {
          name  = "GITHUB_CLIENT_ID"
          value = jsondecode(data.aws_secretsmanager_secret_version.auth_server_github_client.secret_string)["github_client_id"]
        },
        {
          name  = "GITHUB_CLIENT_SECRET"
          value = jsondecode(data.aws_secretsmanager_secret_version.auth_server_github_client.secret_string)["github_client_secret"]
        },
        {
          name  = "GOOGLE_CLIENT_ID"
          value = jsondecode(data.aws_secretsmanager_secret_version.auth_server_google_client.secret_string)["google_client_id"]
        },
        {
          name  = "GOOGLE_CLIENT_SECRET"
          value = jsondecode(data.aws_secretsmanager_secret_version.auth_server_google_client.secret_string)["google_client_secret"]
        },
        {
          name  = "PRIVATE_KEY"
          value = jsondecode(data.aws_secretsmanager_secret_version.auth_server_private_key.secret_string)["private_key"]
        },
        {
          name  = "PUBLIC_KEY"
          value = jsondecode(data.aws_secretsmanager_secret_version.auth_server_public_key.secret_string)["public_key"]
        }
      ]
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 8080
        }
      ]
      healthCheck : {
        command : ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:9000${var.auth_server_health_check_path} || exit 1"]
        interval : 30
        timeout : 5
        retries : 3
        startPeriod : 60
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  tags = var.resource_tags
}

# Creating an ECS service
resource "aws_ecs_service" "auth-server" {
  name                               = "auth-server-service-${var.env}"
  iam_role                           = aws_iam_role.ecs_service_role.arn
  cluster                            = aws_ecs_cluster.nowhere_ecs.id
  task_definition                    = aws_ecs_task_definition.auth_server_task.arn
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 300
  desired_count                      = 2


  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.auth-server-service.arn
    container_name   = "spring-auth-server"
    container_port   = 9000
  }
  ## Spread tasks evenly across all Availability Zones for High Availability
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  # Redeploy Service On Every Apply
  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }

  capacity_provider_strategy {
    base              = 1 # minimum number of tasks to run
    weight            = 1 # share with other capacity providers
    capacity_provider = aws_ecs_capacity_provider.auth_server_group.name
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # You can utilize the generic Terraform resource lifecycle configuration block with ignore_changes
  # to create an ECS service with an initial count of running instances, then ignore any changes to
  # that count caused externally (e.g., Application Autoscaling).
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_iam_role_policy.ecs_service_role_policy]

  tags = var.resource_tags
}

## Create an ECS Capacity Provider
# It till handle the auto scaling of the ECS tasks for the selected auto scaling group.
# Trigger an alarm for the auto scaling group to scale in or out.
resource "aws_ecs_capacity_provider" "auth_server_group" {
  name = "auth-server-cp-${var.env}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.auth_server_service.arn
    # it should be the same for the auto scaling group
    managed_termination_protection = "ENABLED"

    managed_scaling {
      instance_warmup_period    = var.instance_warmup_period
      maximum_scaling_step_size = var.maximum_scaling_step_size
      minimum_scaling_step_size = var.minimum_scaling_step_size
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }
  tags = var.resource_tags
}

## Associate Capacity Provider with ECS Cluster
# The capacity providers associated with the cluster to be used in the capacity provider strategy associated with the service.
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.nowhere_ecs.name
  capacity_providers = [aws_ecs_capacity_provider.auth_server_group.name]
}

