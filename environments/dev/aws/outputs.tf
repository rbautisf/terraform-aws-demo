# Terraform stores all output values, including those marked as sensitive, as plain text in your state file.

## Output the VPC, subnets and security group
output "vpc_id" {
  description = "ID of project VPC"
  value       = aws_vpc.main_vpc.id
}
output "public_subnet_ids" {
  description = "The ID of the public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "The ID of the private subnets"
  value       = aws_subnet.private.*.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.vpc_internet_gateway.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "The ID of the private route tables"
  value       = aws_route_table.private.*.id
}

output "nat_gateway_ids" {
  description = "The ID of the NAT gateways"
  value       = aws_nat_gateway.nat_gateway.*.id
}

output "elastic_ip_id" {
  description = "The ID of the Elastic IPs"
  value       = aws_eip.nat_gateway_elastic_ip.*.id
}

## Output the ALB details
output "alb_url" {
  value = aws_alb.alb.dns_name
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = aws_security_group.alb.id
}


## Output the RDS details
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.postgres.address
  sensitive   = false
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
  sensitive   = false
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}


## Output the ECS details
output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.nowhere_ecs.name
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.auth-server.name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition."
  value       = aws_ecs_task_definition.auth_server_task.arn
}

output "launch_template_id" {
  description = "The id of the EC2 launch template."
  value       = aws_launch_template.ecs_launch_template_x86_64.id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.ecs_log_group.name
}

output "ecs_capacity_provider_name" {
  description = "The name of the ECS capacity provider."
  value       = aws_ecs_capacity_provider.auth_server_group.name
}

output "autoscaling_group_name" {
  description = "The name of the created Auto Scaling Group."
  value       = aws_autoscaling_group.auth_server_service.name
}


## Output th Bastion details
output "bastion_public_dns" {
  description = "The public DNS of the Bastion host"
  value       = aws_instance.bastion_host.public_dns
}

output "bastion_public_ip" {
  description = "The public IP address of the Bastion host"
  value       = aws_instance.bastion_host.public_ip
}

output "private_key" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.auth_server_private_key.secret_string)["private_key"]
  sensitive = true
}

output "public_key" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.auth_server_public_key.secret_string)["public_key"]
  sensitive = true
}


output "redis_primary_endpoint" {
  description = "The endpoint of the ElastiCache Redis replication group"
  value       = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
}

output "redis_read_endpoints" {
  description = "The endpoints of the ElastiCache Redis replication group"
  value       = aws_elasticache_replication_group.redis_replication_group.reader_endpoint_address
}