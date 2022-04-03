terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
    tfe = {
      version = "~> 0.27.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_key
  secret_key = var.aws_secret
}

provider "github" {
  token = var.github_token
}

provider "tfe" {
  token = var.tfc_token
}

data "aws_s3_object" "config" {
  bucket = "famkraai-iac-aws-org"
  key    = "vars.yaml"
  provider = aws.s3
}

# AWS Account IAM provider
provider "aws" {
  alias      = "iam"
  region     = "eu-central-1"
  access_key = var.aws_key
  secret_key = var.aws_secret
  assume_role {
    role_arn     = var.aws_iam_role
  }
}

# AWS Account ssoandorg provider
provider "aws" {
  alias      = "ssoandorg"
  region     = "eu-central-1"
  access_key = var.aws_key
  secret_key = var.aws_secret
  assume_role {
    role_arn     = var.aws_ssoandorg_role
  }
}

# AWS Account s3 provider
provider "aws" {
  alias      = "s3"
  region     = "eu-central-1"
  access_key = var.aws_key
  secret_key = var.aws_secret
  assume_role {
    role_arn     = var.aws_s3_role
  }
}

