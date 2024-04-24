variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "terraform_organization" {
  description = "Terraform organization"
  type        = string
}

variable "terraform_workspace" {
  description = "Terraform workspace"
  type        = string
}
