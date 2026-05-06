# 🔐 DOTWEB DevSecOps CI/CD Security Pipeline
 
> **DOTWEB Enterprise & Business Applications** — Automated 9-Stage Security Gate Pipeline
 
[![DevSecOps Pipeline](https://github.com/YOUR_USERNAME/dotweb-devsecops-pipeline/actions/workflows/devsecops-pipeline.yml/badge.svg)](https://github.com/YOUR_USERNAME/dotweb-devsecops-pipeline/actions)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS Free Tier](https://img.shields.io/badge/AWS-Free%20Tier%20Safe-FF9900?logo=amazon-aws)](https://aws.amazon.com/free/)
 
---
 
## What This Project Does
 
An enterprise-grade DevSecOps CI/CD security pipeline that integrates 8+ security tools into a fully automated GitHub Actions workflow. Security gates automatically block deployments when CRITICAL or HIGH vulnerabilities are detected. All AWS infrastructure is managed by Terraform and runs within the AWS Free Tier.
 
## 9-Stage Pipeline
 
| Stage | Tool | Catches |
|-------|------|---------|
| 1. Secrets Scan | TruffleHog | API keys, tokens in code |
| 2. SAST | Bandit + Semgrep | Injection, insecure patterns |
| 3. SCA | pip-audit | Vulnerable dependencies |
| 4. IaC Scan | tfsec | Terraform misconfigurations |
| 5. Build | Docker | Multi-stage secure image |
| 6. Container Scan | Trivy | CVEs inside the image |
| 7. Push to ECR | AWS ECR | Store verified image |
| 8. ECR Scan | AWS Native | Cloud-native image scan |
| 9. Security Report | Markdown + S3 | Aggregated audit report |
 
## AWS Free Tier Statement
 
> ⚠️ This project is designed to run entirely within the AWS Free Tier.
 
| Service | Free Tier Limit | How This Project Stays Free |
|---------|----------------|-----------------------------|
| Amazon ECR | 500 MB/month | Lifecycle policy: max 5 images |
| Amazon S3 | 5 GB storage | 30-day auto-expiry on reports |
| IAM / OIDC | Always free | No charges |
| GitHub Actions | 2,000 min/month (public repos: unlimited) | All compute on GitHub runners |
 
**To destroy all resources:** `cd terraform && terraform destroy`
 
## Tech Stack
 
`GitHub Actions` · `Terraform` · `AWS ECR` · `AWS S3` · `AWS IAM` · `OIDC` · `Docker` · `Python 3.12` · `TruffleHog` · `Bandit` · `Semgrep` · `pip-audit` · `tfsec` · `Trivy`
 
## Quick Start
 
```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/dotweb-devsecops-pipeline.git
cd dotweb-devsecops-pipeline
 
# 2. Configure AWS and Terraform
aws configure
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GitHub username
 
# 3. Provision AWS infrastructure
terraform init && terraform plan && terraform apply
 
# 4. Add Terraform outputs as GitHub Secrets
# AWS_ROLE_ARN, S3_REPORTS_BUCKET, AWS_REGION
 
# 5. Push to trigger pipeline
git push origin main
```
 
## Project Structure
 
```
dotweb-devsecops-pipeline/
├── .github/workflows/
│   └── devsecops-pipeline.yml   # 9-stage pipeline
├── app/
│   ├── app.py                   # Flask application
│   ├── Dockerfile               # Multi-stage Docker build
│   └── requirements.txt
├── terraform/
│   ├── main.tf                  # Provider config
│   ├── variables.tf             # All variables
│   ├── resources.tf             # ECR, S3, IAM resources
│   ├── outputs.tf               # Terraform outputs
│   └── terraform.tfvars.example
└── README.md
```
 
---
*DOTWEB Enterprise & Business Applications — DevSecOps Engineering*
