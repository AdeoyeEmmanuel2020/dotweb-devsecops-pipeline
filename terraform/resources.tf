###############################################################
# DOTWEB DevSecOps Pipeline — Core AWS Resources
# ALL resources are AWS Free Tier eligible
###############################################################
 
# ─────────────────────────────────────────────────────────────
# DATA SOURCES
# ─────────────────────────────────────────────────────────────
 
data "aws_caller_identity" "current" {}
 
data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}
 
# ─────────────────────────────────────────────────────────────
# GITHUB OIDC PROVIDER
# Allows GitHub Actions to authenticate with AWS — no keys needed
# ─────────────────────────────────────────────────────────────
 
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0
 
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
 
# ─────────────────────────────────────────────────────────────
# IAM ROLE FOR GITHUB ACTIONS (Least Privilege)
# ─────────────────────────────────────────────────────────────
 
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })
}
 
resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "ecr-push-policy"
  role = aws_iam_role.github_actions.id
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = aws_ecr_repository.app.arn
      },
      {
        Sid    = "S3Reports"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.pipeline_reports.arn,
          "${aws_s3_bucket.pipeline_reports.arn}/*"
        ]
      }
    ]
  })
}
 
# ─────────────────────────────────────────────────────────────
# ECR REPOSITORY (Free Tier: 500 MB/month storage)
# ─────────────────────────────────────────────────────────────
 
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
 
  image_scanning_configuration {
    scan_on_push = true
  }
 
  encryption_configuration {
    encryption_type = "AES256"
  }
}
 
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
 
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 5 images (Free Tier protection)"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
 
# ─────────────────────────────────────────────────────────────
# S3 BUCKET — SECURITY REPORTS (Free Tier: 5 GB storage)
# ─────────────────────────────────────────────────────────────
 
resource "aws_s3_bucket" "pipeline_reports" {
  bucket        = "${var.project_name}-${var.pipeline_bucket_suffix}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}
 
resource "aws_s3_bucket_versioning" "pipeline_reports" {
  bucket = aws_s3_bucket.pipeline_reports.id
  versioning_configuration {
    status = "Enabled"
  }
}
 
resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_reports" {
  bucket = aws_s3_bucket.pipeline_reports.id
 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
 
resource "aws_s3_bucket_public_access_block" "pipeline_reports" {
  bucket = aws_s3_bucket.pipeline_reports.id
 
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
 
resource "aws_s3_bucket_lifecycle_configuration" "pipeline_reports" {
  bucket = aws_s3_bucket.pipeline_reports.id
 
  rule {
    id     = "expire-old-reports"
    status = "Enabled"
 
    expiration {
      days = 30
    }
  }
}
