terraform {
  backend "s3" {
    bucket         = "demo-devops-project-2024"
    region         = "eu-central-1"
    key            = "Demo-Devops-Project/terraform.tfstate"
    dynamodb_table = "terraform-tfstate"
    encrypt        = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}
