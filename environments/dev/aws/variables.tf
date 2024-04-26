variable "aws_cli_profile_sso" {
  description = "AWS profile to use."
  type        = string
}

variable "resource_tags" {
  description = "Tags to set for all resources."
  type        = map(string)
  default = {
    "env" = "dev"
  }
}

variable "env" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}
variable "terraform_org" {
  description = "Name of the Terraform workspace."
  type        = string
}
variable "terraform_workspace" {
  description = "Name of the Terraform workspace."
  type        = string
}
# AWS
variable "region" {
  description = "List of AWS regions."
  type        = string
  default     = "us-east-1"
}

# Virtual Private Cloud Subnet - Classless Inter-Domain Routing  
variable "vpc_cidr" {
  description = "CIDR block for VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# Availabilty Zones should match previous
variable "az_count" {
  description = "Describes how many availability zones are used."
  default     = 2
  type        = number
}

## EC2 Public Key for SSH access
variable "public_ec2_key" {
  description = "Public key for SSH access to EC2 instances."
  type        = string
}

# Bastion Host
variable "bastion_instance_type" {
  description = "Instance type for bastion host."
  type        = string
  default     = "t2.nano"
}

# ECS
variable "asc_min_instances" {
  description = "Minimun number of intances running, desired."
  type        = number
  default     = 1
}

variable "asc_max_instances" {
  description = "Maximun number of intances running, desired."
  type        = number
  default     = 2
}

variable "auth_server_image" {
  description = "Authorization server image."
  type        = string
}

variable "auth_server_health_check_path" {
  description = "Authorization server health check path."
  type        = string
  default = "/auth-server/actuator/health"
}


## RDS details
variable "db_instance_class" {
  description = "Database instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name."
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database administrator username."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}

# ECS CAPACITY PROVIDER
variable "instance_warmup_period" {
  description = "The amount of time, in seconds, that Amazon ECS should wait between target capacity updates."
  default     = 300
  type        = number
}
variable "maximum_scaling_step_size" {
  description = " Maximum step adjustment size. A number between 1 and 10,000."
  default     = 3
  type        = number
}

variable "minimum_scaling_step_size" {
  description = "Minimum step adjustment size. A number between 1 and 10,000."
  default     = 1
  type        = number
}

variable "target_capacity" {
  description = "Target utilization for the capacity provider. A number between 1 and 100(%)."
  default     = 100
  type        = number
}


# CloudWatch
variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events in the log group."
  type        = number
  default     = 1
}

########## SECRET MANAGER ########
variable "auth_server_private_key" {
  description = "Authorization server private key."
  type        = string
  sensitive   = true
}
variable "auth_server_public_key" {
  description = "Authorization server public key."
  type        = string
  sensitive   = true
}

variable "auth_server_github_secret" {
  description = "Authorization server GitHub secret."
  type        = string
  sensitive   = true
}

variable "auth_server_google_secret" {
  description = "Authorization server Google secret."
  type        = string
  sensitive   = true
}

variable "github_packages_credentials" {
  description = "GitHub packages credentials."
  type        = string
  sensitive   = true
}
##################