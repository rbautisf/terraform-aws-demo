terraform {

  cloud {
    organization = var.terraform_organization
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