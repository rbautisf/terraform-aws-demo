
# Terraform AWS EC2 Instance

This project contains Terraform scripts to provision an AWS EC2 instance with Ubuntu 20.04.

## Prerequisites

- Terraform v1.2 or later
- AWS IDP configured.

## Files

- `terraform.tf`: Specifies the required Terraform version and AWS provider version.
- `variables.tf`: Contains the variable definitions required for the AWS provider and EC2 instance.
- `outputs.tf`: Defines the outputs after the EC2 instance is created.
- `main.tf`: Contains the AWS provider configuration and the resources to be created.

## Usage

This code is meant to be used with Terraform Cloud. To run the code, follow these steps:

1. Clone the repository.
2. Create a new workspace in Terraform Cloud.
3. Link the workspace to the repository.
4. Set the required environment variables in the workspace.
5. Set the AWS IDP [Guide](https://aws.amazon.com/blogs/apn/simplify-and-secure-terraform-workflows-on-aws-with-dynamic-provider-credentials/)
6. Queue a plan in the workspace to create the EC2 instance.
7. Apply the plan to create the EC2 instance.
8. Verify that the EC2 instance was created successfully.
9. Destroy the EC2 instance when it is no longer needed.
