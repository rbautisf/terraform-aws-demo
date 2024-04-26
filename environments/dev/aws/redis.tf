# Redis Cluster Mode Disabled Read Replica Instance
# In this situation, you will need to utilize the lifecycle configuration block
# with ignore_changes to prevent perpetual differences during Terraform plan
# with the num_cache_cluster attribute.
resource "aws_elasticache_cluster" "replica" {
  count                = 1
  cluster_id           = "tf-rep-group-1-${count.index}"
  replication_group_id = aws_elasticache_replication_group.redis_replication_group.id
}

resource "aws_elasticache_replication_group" "redis_replication_group" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  replication_group_id        = "replication-group-az"
  description                 = "Description about the Replication Group"
  node_type                   = "cache.t2.micro"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  engine_version              = "7.1"
  port                        = 6379
  subnet_group_name           = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids          = [aws_security_group.elasticache_redis.id, aws_security_group.ecs_ec2.id]

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "subnet-group-redis"
  subnet_ids = aws_subnet.private[*].id
}