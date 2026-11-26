terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state: enable after you create the S3 bucket by hand or in a separate bootstrap step
  # backend "s3" {
  #   bucket       = "your-unique-tfstate-bucket"
  #   key          = "eks-project/terraform.tfstate"
  #   region       = "ap-south-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "client-portal"
      ManagedBy   = "terraform"
    }
  }
}