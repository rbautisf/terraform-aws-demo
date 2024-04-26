# The AWS provider is responsible for creating and managing resources on AWS.
provider "aws" {
  # The AWS region in which to create the resources.
  region = var.region

  # Optional: If you are using AWS SSO, you can specify the profile name here.
  # The AWS CLI profile to use for authentication. This allows you to use the same
  # authentication credentials in the AWS CLI and Terraform.
#   profile = var.aws_cli_profile_sso
}