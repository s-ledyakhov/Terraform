terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "terraform-tfstate"
    region = "us-east-1"
    key = "prod/network"
  }
}

provider "aws" {
  region = "us-east-1"
}
