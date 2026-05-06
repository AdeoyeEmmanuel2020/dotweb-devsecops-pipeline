###############################################################
# DOTWEB DevSecOps Pipeline — Outputs
###############################################################
 
output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = aws_ecr_repository.app.repository_url
}
 
output "s3_reports_bucket" {
  description = "S3 bucket name for storing pipeline security reports"
  value       = aws_s3_bucket.pipeline_reports.bucket
}
 
output "iam_role_arn" {
  description = "IAM Role ARN for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}
 
output "aws_region" {
  description = "AWS region in use"
  value       = var.aws_region
}
