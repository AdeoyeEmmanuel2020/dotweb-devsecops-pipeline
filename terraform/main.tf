###############################################################
# DOTWEB Enterprise & Business Applications
# Project: DevSecOps CI/CD Security Pipeline
# Managed by: Terraform | AWS Free Tier Safe
###############################################################
 
terraform {
  required_version = ">= 1.3.0"
 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
provider "aws" {
  region = var.aws_region
 
  default_tags {
    tags = {
      Project     = "dotweb-devsecops-pipeline"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Company     = "DOTWEB"
      CostCenter  = "FreeTier"
    }
  }
}
