# Declaration for the providers and cloud
terraform {
  #  Configuration for the remote backend
    cloud {
      organization = var.terraform_org

      workspaces {
        name = var.terraform_workspace
      }
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
  required_version = "~> 1.2"
}

