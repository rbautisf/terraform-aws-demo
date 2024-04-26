# Getting Started

This is a sample project demonstrating the use of Terraform Cloud and AWS as the provider.

# Terraform AWS Infrastructure

This project contains the Terraform scripts for setting up the AWS infrastructure for the NowhereLearn Authorization Server application. The infrastructure includes a VPC, ECS cluster, RDS instance, ElastiCache Redis instance, and an Application Load Balancer.

### Note regarding potential charges
Please be aware that the implementation of these services may incur charges, even if your account is under the AWS Free Tier. The AWS Free Tier includes offers that are free for 12 months following your initial sign-up date, as well as additional short-term free trial offers and always free offers. However, usage beyond the Free Tier limits or for services not covered by the Free Tier will be billed at the standard rates.
It is always a good practice to monitor your usage through the AWS Management Console to ensure it remains within the Free Tier limits. Also, consider implementing cost management tools such as AWS Cost Explorer and AWS Budgets to help track your spending. 

## Prerequisites

- [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) (Optional if using Terraform Cloud)
- [Terraform Cloud](https://app.terraform.io/public/signup/account) (Optional if using Terraform CLI)
- [AWS ACCOUNT](https://aws.amazon.com/resources/create-account/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) 
  - [SSO Configuration](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso) (Optional if using Terraform Cloud but required if using Terraform CLI and SSO)
  - [Access and Secret Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey_CLIAPI) (Optional if using Terraform Cloud but required if using Terraform CLI and Access Keys)
  - [AWS Dynamic Provider Credentials](https://aws.amazon.com/blogs/apn/simplify-and-secure-terraform-workflows-on-aws-with-dynamic-provider-credentials/)

## Terraform Variables (tfvars)

Create a `secret.tfvars` file in the `environments/dev/aws` directory with the following variables or define the Terraform variables if using Terraform Cloud:

```hcl
# Terraform CLI SSO Profile (Not required if using Terraform Cloud)
aws_cli_profile_sso = "(Optional if using Terraform Cloud) Specifies the AWS profile to use for deployment."
# Terraform Cloud Variables (Not required if using Terraform CLI)
terraform_org       = "The organization associated with the deployment."
terraform_workspace = "The Terraform workspace where the deployment should occur."
# DB Variables
db_username         = "The username for your database."
db_password         = "The password for your database."
db_name             = "The name of your database."
# Public Key for EC2 Instances
public_ec2_key      = "The public key for EC2 instances being launched as part of the deployment."
# Auth Server Variables
auth_server_image = "Docker image for the authentication server."
auth_server_private_key     = "Path to the private key for the auth server."
auth_server_public_key      = "Path to the public key for the auth server."
auth_server_github_secret   = "Path to Github client secret."
auth_server_google_secret   = "Path to Google client secret."
# Github Packages Credentials
github_packages_credentials = "Path to Github Packages credentials."
```

Note: for the public and private key bear in mind the "/b" at the end of each line when storing the key pair value in AWS Secrets Manager. 


### Public Key for EC2 Instances and Bastion Host

The `public_ec2_key` variable should contain the public key that will be used to access the EC2 instances. You can generate a new key pair using the following command:

```bash
ssh-keygen -t rsa -b 4096
```

This will generate a new key pair. The public key will be stored in the `~/.ssh/id_rsa.pub` file. You can copy the contents of this file and paste it into the `public_ec2_key` variable in the `secret.tfvars` file. 

## Terraform CLI

If you are using the Terraform CLI, you can run the Terraform commands to apply the Terraform scripts. You will need to have the AWS CLI installed and configured with the necessary permissions to create and manage the AWS resources.

### Terraform CLI Commands

```bash
# Change to the Terraform directory
cd environments/dev/aws

# Initialize the Terraform workspace
terraform init

# Plan the Terraform deployment
terraform plan -var-file="secret.tfvars"

# Apply the Terraform deployment
terraform apply -var-file="secret.tfvars" -auto-approve

# Destroy the Terraform deployment
terraform destroy -var-file="secret.tfvars" -auto-approve
```

Please replace "secret.tfvars" with your own secret variables file.

## Terraform Cloud

If you are using Terraform Cloud, you can set up the Terraform Cloud workspace and link it to your GitHub repository. You can then trigger the Terraform Cloud run to apply the Terraform scripts.

### Terraform Cloud Configuration

1. Create a new organization in Terraform Cloud.
2. Create a new workspace in the organization.
3. Link the workspace to your GitHub repository.
4. Set up the workspace variables in Terraform Cloud using the variables defined in the `secret.tfvars` file.
5. Queue a new run in Terraform Cloud to apply the Terraform scripts.

## AWS Resources Created
The following AWS resources are created by these scripts:
- VPC with public and private subnets
- Internet Gateway and NAT Gateway for internet access
- Security Groups for different resources
- ECS Cluster, Task Definition, and Service
- Application Load Balancer
- RDS PostgreSQL instance
- ElastiCache Redis instance
- Bastion Host for secure access
- Auto Scaling Group for ECS tasks
- IAM roles and policies for ECS tasks and services

### Bastion Host
The bastion host is set up to provide secure access to the private resources in the VPC. It is launched in a public subnet and allows SSH access from a specific IP address. You can use the bastion host to SSH into the private instances in the VPC.

```bash
# Add the private key to the SSH agent
ssh-add ~/.ssh/your_private_key

# SSH into the bastion host
ssh -A ec2-user@<bastion-public-ip>

# SSH into the private instance from the bastion host
ssh ec2-user@<private-instance-private-ip>
```

### Directory Structure
- **bastion.tf**: This file sets up the bastion host for secure access to the private resources.
- **data_sources.tf**: This file contains data sources for retrieving information from AWS.
- **ecs.tf**: This file sets up the ECS cluster, task definitions, and services.
- **ecs_auto_scale.tf**: This file sets up the auto scaling for the ECS service.
- **iam.tf**: This file sets up the IAM roles and policies needed for the ECS service and tasks.
- **load_balancer.tf**: This file sets up the Application Load Balancer for the ECS service.
- **main.tf**: This is the main entry point for Terraform. It sets up the AWS provider.
- **outputs.tf**: This file declares all the outputs that Terraform will print after applying the configuration.
- **postgres.tf**: This file sets up the RDS PostgreSQL database.
- **redis.tf**: This file sets up the ElastiCache Redis cluster.
- **security_groups.tf**: This file sets up the security groups for different resources.
- **terraform.tf**: This file sets up the Terraform backend configuration.
- **variables.tf**: This file declares all the variables used in the Terraform configuration.
- **vpc.tf**: This file sets up the VPC, including subnets, NAT gateways, and route tables.

## AWS CLI Commands
    
```bash
# Create a new profile for AWS CLI
aws configure sso

# SSO login
aws sso login --profile <profile-name>

```
