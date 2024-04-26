## Application Load Balancer in public subnets with HTTP default listener that redirects traffic to HTTPS
resource "aws_alb" "alb" {
  name            = "alb-${var.env}"
  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.public.*.id
  tags            = var.resource_tags
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.auth-server-service.arn
  }
  tags = var.resource_tags
}

resource "aws_alb_target_group" "auth-server-service" {
  name                 = "auth-server-service-tg${var.env}"
  port                 = "8080" # same as load balancer port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main_vpc.id
  deregistration_delay = 300

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    matcher             = 200
    path                = var.auth_server_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "30"
  }

  depends_on = [aws_alb.alb]
  tags       = var.resource_tags
}
