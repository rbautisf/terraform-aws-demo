resource "aws_launch_template" "ecs_launch_template_x86_64" {
  name          = "ecs-launch-template-x86_64-${var.env}"
  image_id      = data.aws_ami.amazon_linux_2_x86_64.id
  instance_type = "t2.micro"
  # set the instance to be part of the ECS cluster
  user_data              = base64encode(data.template_file.user_data.rendered)
  vpc_security_group_ids = [aws_security_group.ecs_ec2.id]
  # For ssh access
  key_name = aws_key_pair.default.key_name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance_role_profile.arn
  }
  # lifecycle configuration to create the instance before destroying the old one
  lifecycle {
    create_before_destroy = true
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-launch-template-x86_64-${var.env}"
    }

  }
}


## Provides an Application AutoScaling ScalableTarget resource. To manage policies which get attached
# to the target, see the aws_appautoscaling_policy resource.
resource "aws_appautoscaling_target" "ecs_service_auth_server" {
  max_capacity       = 6
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.nowhere_ecs.name}/${aws_ecs_service.auth-server.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

## Policy for CPU tracking
resource "aws_appautoscaling_policy" "ecs_cpu_policy_auth_server_service" {
  name               = "auth-server-service-cpu-policy-${var.env}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_auth_server.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_auth_server.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_auth_server.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      # https://docs.aws.amazon.com/autoscaling/application/APIReference/API_PredefinedMetricSpecification.html
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

}

## Policy for memory tracking
resource "aws_appautoscaling_policy" "ecs_memory_policy_auth_server_service" {
  name               = "auth-server-service-memory-policy-${var.env}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_auth_server.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_auth_server.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_auth_server.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

## Create an ECS AutoScaling Group
resource "aws_autoscaling_group" "auth_server_service" {
  name             = "auth-server-service-asg-${var.env}"
  max_size         = 6
  min_size         = 1
  desired_capacity = 2

  # List of subnet IDs to launch resources in.
  vpc_zone_identifier = aws_subnet.private.*.id
  health_check_type   = "EC2"
  health_check_grace_period = 300
  # Capacity provider must set managed_termination_protection as Enabled
  protect_from_scale_in = true
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.ecs_launch_template_x86_64.id
    version = "$Latest"
  }

  # Associating an ECS Capacity Provider to an Auto Scaling Group will automatically add the AmazonECSManaged tag
  # to the Auto Scaling Group. This tag should be included in the aws_autoscaling_group resource configuration to
  # prevent Terraform from removing it in subsequent executions as well as ensuring the AmazonECSManaged tag is
  # propagated to all EC2 Instances in the Auto Scaling Group if min_size is above 0 on creation.
  # Any EC2 Instances in the Auto Scaling Group without this tag must be manually be updated, otherwise
  # they may cause unexpected scaling behavior and metrics.


  instance_refresh {
    strategy = "Rolling"
  }

  lifecycle {
    create_before_destroy = true
  }

  # Define tag for ECS managed to prevent terraform from removing it.
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}
