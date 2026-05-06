###############################################################
# DOTWEB DevSecOps Pipeline — Variables
###############################################################
 
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
 
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
 
variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "dotweb-devsecops"
}
 
variable "ecr_repo_name" {
  description = "ECR repository name for pipeline container images"
  type        = string
  default     = "dotweb-app"
}
 
variable "pipeline_bucket_suffix" {
  description = "Unique suffix for the S3 bucket"
  type        = string
  default     = "pipeline-reports"
}
 
variable "github_org" {
  description = "Your GitHub username or organisation name"
  type        = string
}
 
variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
  default     = "dotweb-devsecops-pipeline"
}
 
variable "create_oidc_provider" {
  description = "Set to true on first run. Set to false if OIDC provider already exists."
  type        = bool
  default     = true
}
