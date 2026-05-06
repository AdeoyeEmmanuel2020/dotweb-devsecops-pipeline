<div align="center">

<img src="https://img.shields.io/badge/DOTWEB-Enterprise_%26_Business_Applications-0a0a0a?style=for-the-badge&labelColor=0a0a0a&color=e63946" alt="DOTWEB"/>

# DevSecOps CI/CD Security Pipeline

### Automated 9-Stage Security Gate System — AWS · GitHub Actions · Terraform

<br/>

[![Pipeline Status](https://img.shields.io/badge/Pipeline-Passing-28a745?style=flat-square&logo=github-actions&logoColor=white)](https://github.com/AdeoyeEmmanuel2020/dotweb-devsecops-pipeline/actions)
[![Terraform](https://img.shields.io/badge/IaC-Terraform_1.3+-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS Free Tier](https://img.shields.io/badge/AWS-Free_Tier_Safe-FF9900?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/free/)
[![Security Tools](https://img.shields.io/badge/Security_Tools-8+-e63946?style=flat-square&logo=security&logoColor=white)](#security-tools)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Docker](https://img.shields.io/badge/Container-Docker_Multi--Stage-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)

<br/>

> **An enterprise-grade DevSecOps CI/CD pipeline integrating 8+ automated security tools  
> with zero-trust AWS infrastructure, keyless OIDC authentication, and full audit trail.**

<br/>
</div>

----
## Table of Contents

- [About This Project](#about-this-project)
- [Architecture](#architecture)
- [Architecture Decisions and Rationale](#architecture-decisions-and-rationale)
- [Security Controls Implemented](#security-controls-implemented)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Module Documentation](#module-documentation)
- [Compliance Alignment](#compliance-alignment)
- [Deployed Infrastructure — Live Resource IDs](#deployed-infrastructure--live-resource-ids)
- [Terminal Evidence — CLI](#-terminal-evidence--cli)
- [AWS Console Evidence](#-aws-console-evidence)
- [Destroy Infrastructure](#destroy-infrastructure)
- [Enabling GuardDuty and Security Hub](#enabling-guardduty-and-security-hub)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

---

##  Overview

This project delivers a **production-grade DevSecOps CI/CD security pipeline** built for DOTWEB Enterprise & Business Applications. It embeds security at every stage of the software delivery lifecycle — from the first line of code to the final container running in production.

Security is not bolted on at the end. Every commit triggers an automated cascade of 9 security stages. Code that carries secrets, vulnerable dependencies, or insecure container images is physically blocked from reaching production by automated security gates. All findings are uploaded to GitHub's native Security tab via SARIF, and a consolidated audit report is stored in encrypted S3 after every run.

### What This System Enforces

| Concern | Enforcement |
|---------|-------------|
| Exposed credentials in code | TruffleHog scans every commit for verified secrets |
| Insecure Python patterns | Bandit + Semgrep catch OWASP Top 10 issues pre-build |
| Vulnerable dependencies | pip-audit checks every package against the CVE database |
| Misconfigured infrastructure | tfsec validates Terraform against AWS security benchmarks |
| Vulnerable container images | Trivy scans the Docker image before it reaches ECR |
| Post-push container integrity | AWS ECR native scanner runs a second pass after push |
| Audit trail | Every scan result uploaded to encrypted S3 with 30-day retention |
| Keyless AWS authentication | GitHub OIDC — no long-lived access keys stored anywhere |

---

##  Architecture

<img width="700" height="400" alt="Architecture_diagram" src="https://github.com/user-attachments/assets/bbfba397-7423-4f50-a350-d3d9d6dc5a4d" />


---

##  Pipeline Stages

### Stage 1 · Secrets Scanning — TruffleHog

Scans the full repository history for verified secrets — API keys, tokens, database passwords, private keys, and OAuth credentials. Uses entropy analysis and pattern matching against 700+ detectors. Runs on every push before any other stage.

```
Tool:     TruffleHog (trufflesecurity/trufflehog@main)
Blocks:   Verified exposed credentials
Scope:    Full repository history
Output:   trufflehog-results.json → GitHub Artifact
```

---

### Stage 2 · SAST — Bandit + Semgrep

Two complementary static analysis tools run in parallel. Bandit specialises in Python security anti-patterns. Semgrep runs 583+ rules covering Python, Dockerfile, YAML, and Terraform — including the full OWASP Top 10 ruleset. Both upload SARIF results directly to the GitHub Security tab.

```
Tools:    Bandit (Python SAST) + Semgrep (multi-language)
Rules:    583+ rules — p/python, p/owasp-top-ten, p/secrets
Blocks:   HIGH and CRITICAL severity findings
Output:   bandit-results.sarif + semgrep-results.sarif → GitHub Security tab
```

---

### Stage 3 · SCA — pip-audit

Software Composition Analysis. Audits every Python dependency declared in `requirements.txt` against the OSV (Open Source Vulnerabilities) database and PyPI Advisory Database. Generates a full dependency vulnerability report including CVE IDs and fix versions.

```
Tool:     pip-audit
Database: OSV + PyPI Advisory DB
Scope:    All direct and transitive dependencies
Output:   sca-results.json → GitHub Artifact
```

---

### Stage 4 · IaC Security — tfsec

Scans all Terraform configuration files against 150+ AWS security checks. Detects misconfigurations such as publicly accessible S3 buckets, unencrypted storage, permissive IAM policies, and missing security controls. Results are uploaded to the GitHub Security tab as SARIF.

```
Tool:     tfsec (aquasecurity/tfsec)
Scope:    terraform/ directory — all .tf files
Checks:   AWS CIS Benchmark, HIPAA, SOC 2 controls
Output:   tfsec-results.sarif → GitHub Security tab
```

---

### Stage 5 · Build — Docker Multi-Stage

Builds the application container using a multi-stage Dockerfile. The build stage installs all dependencies. The runtime stage copies only what is needed — producing a minimal image with a reduced attack surface. The container runs as a non-root user. The image is saved as a GitHub Actions artifact and passed to the container scanning stage.

```
Tool:     Docker Buildx (multi-stage)
Security: Non-root user, minimal runtime image
Cache:    GitHub Actions cache (speeds up subsequent builds)
Output:   docker-image.tar → GitHub Artifact
```

---

### Stage 6 · Container Scanning — Trivy

Scans the built Docker image for known CVEs in OS packages (Alpine/Debian), Python packages, and application libraries. Runs two passes — one producing SARIF for the GitHub Security tab, one producing a human-readable table in the job logs. A security gate blocks the pipeline if CRITICAL vulnerabilities are found.

```
Tool:     Trivy (aquasecurity/trivy-action@master)
Scope:    OS packages + Python packages inside the container
Severity: CRITICAL and HIGH
Output:   trivy-container.sarif → GitHub Security tab
Gate:     Blocks pipeline on CRITICAL findings
```

---

### Stage 7 · Push to ECR — AWS ECR

Pushes the verified, scanned image to Amazon Elastic Container Registry. Authentication uses AWS OIDC — GitHub Actions assumes an IAM role via federated identity. No AWS access keys are stored in GitHub secrets. The image is tagged with both the commit SHA and `latest`.

```
Registry: Amazon ECR (dotweb-app)
Auth:     AWS OIDC (keyless — no long-lived credentials)
Tags:     :latest + :<commit-sha>
Policy:   IMMUTABLE tags — images cannot be overwritten
```

---

### Stage 8 · ECR Scan — AWS Native Scanner

After the image is pushed, AWS ECR's built-in vulnerability scanner performs a second independent scan using the Clair engine. This provides a cloud-native second opinion separate from Trivy. The findings summary is printed to the job logs.

```
Tool:     AWS ECR Basic Scanning (Clair engine)
Trigger:  Automatic on push (scan_on_push = true in Terraform)
Output:   Findings summary in job logs + ECR console
Cost:     Free (included with ECR)
```

---

### Stage 9 · Security Report — Consolidated Audit

Runs after all scan stages complete, regardless of pass or fail. Downloads all scan artifacts, generates a consolidated Markdown report showing the status of every stage, and uploads it to the encrypted S3 bucket with the pipeline run number and commit SHA in the filename. Also saved as a GitHub Actions artifact with 30-day retention.

```
Output:   security-report.md
Storage:  S3: s3://dotweb-devsecops-pipeline-reports-{account}/reports/
          GitHub Artifact: 30-day retention
Triggers: Always — even if upstream stages fail
```

---

## Security Tools

| Tool | Category | Version | What It Catches |
|------|----------|---------|-----------------|
| [TruffleHog](https://github.com/trufflesecurity/trufflehog) | Secrets Detection | Latest | API keys, tokens, passwords in git history |
| [Bandit](https://bandit.readthedocs.io/) | SAST | Latest | Python security anti-patterns, OWASP Top 10 |
| [Semgrep](https://semgrep.dev/) | SAST | Latest | Multi-language patterns, 583+ rules |
| [pip-audit](https://pypi.org/project/pip-audit/) | SCA | Latest | CVEs in Python dependencies |
| [tfsec](https://aquasecurity.github.io/tfsec/) | IaC Security | Latest | Terraform misconfigurations |
| [Trivy](https://trivy.dev/) | Container Scanning | Latest | CVEs in container OS and app packages |
| [AWS ECR Scan](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html) | Container Scanning | Native | Cloud-native image scanning (Clair) |
| [Docker Multi-Stage](https://docs.docker.com/build/building/multi-stage/) | Hardening | Latest | Attack surface reduction |

---

## ☁ AWS Infrastructure

All infrastructure is defined as code in Terraform and provisioned in `us-east-1`.

### Resources

| Resource | Name | Purpose |
|----------|------|---------|
| `aws_ecr_repository` | `dotweb-app` | Container image registry |
| `aws_ecr_lifecycle_policy` | — | Auto-delete images beyond last 5 |
| `aws_s3_bucket` | `dotweb-devsecops-pipeline-reports-{account}` | Security reports storage |
| `aws_s3_bucket_versioning` | — | Report version history |
| `aws_s3_bucket_server_side_encryption_configuration` | — | AES-256 encryption at rest |
| `aws_s3_bucket_public_access_block` | — | Block all public access |
| `aws_s3_bucket_lifecycle_configuration` | — | 30-day auto-expiry |
| `aws_iam_openid_connect_provider` | `token.actions.githubusercontent.com` | GitHub OIDC federation |
| `aws_iam_role` | `dotweb-devsecops-github-actions-role` | Least-privilege role for pipeline |
| `aws_iam_role_policy` | `ecr-push-policy` | ECR push + S3 write permissions |

### IAM Permissions (Least Privilege)

The GitHub Actions IAM role is scoped to the minimum permissions required:

```
ECR:  GetAuthorizationToken, BatchCheckLayerAvailability, PutImage,
      InitiateLayerUpload, UploadLayerPart, CompleteLayerUpload,
      DescribeRepositories, ListImages

S3:   PutObject, GetObject, ListBucket
      (scoped to reports bucket only)
```

### OIDC Trust Policy

```json
{
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub":
        "repo:AdeoyeEmmanuel2020/dotweb-devsecops-pipeline:*"
    }
  }
}
```

No AWS access keys are stored in GitHub. The pipeline authenticates via short-lived OIDC tokens that expire after each job.

---

## AWS Free Tier Compliance

> This project is designed to operate entirely within the AWS Free Tier at zero cost.

| Service | Free Tier Allowance | This Project's Usage | Guard |
|---------|--------------------|-----------------------|-------|
| Amazon ECR | 500 MB storage/month | ~50 MB per image | Lifecycle policy: max 5 images |
| Amazon S3 | 5 GB storage, 2,000 PUT/month | Small Markdown files | 30-day lifecycle expiry |
| AWS IAM | Always free | 1 role, 1 OIDC provider | — |
| GitHub Actions | 2,000 min/month (public: unlimited) | ~8 min/run | Public repo |

**Estimated monthly cost: $0.00**

To destroy all AWS resources:
```bash
cd terraform && terraform destroy
```

---

## Screenshots

> Documentation screenshots from a live pipeline run. All stages executed on commit `5712fe2`.

---

### 01 · Terraform Init
> AWS provider downloaded, backend initialised, working directory prepared.

![Terraform Init](docs/screenshots/01-terraform-init.png)

```
Terraform has been successfully initialized!
Provider: hashicorp/aws ~> 5.0
```

---

### 02 · Terraform Plan
> Preview of all AWS resources to be provisioned — 8 resources, zero existing state conflicts.

![Terraform Plan](docs/screenshots/02-terraform-plan.png)

```
Plan: 8 to add, 0 to change, 0 to destroy.
```

---

### 03 · Terraform Apply — Outputs
> Infrastructure provisioned. ECR repository URL, IAM role ARN, and S3 bucket name emitted as outputs.

![Terraform Apply](docs/screenshots/03-terraform-apply-outputs.png)

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
  ecr_repository_url = "XXXXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/dotweb-app"
  iam_role_arn       = "arn:aws:iam::XXXXXXXXXXXX:role/dotweb-devsecops-github-actions-role"
  s3_reports_bucket  = "dotweb-devsecops-pipeline-reports-XXXXXXXXXXXX"
```

---

### 04 · GitHub Secrets Configuration
> Three repository secrets configured — AWS_ROLE_ARN, S3_REPORTS_BUCKET, AWS_REGION.

![GitHub Secrets](docs/screenshots/04-github-secrets.png)

---

### 05 · Pipeline Overview — All 9 Stages Running
> GitHub Actions workflow DAG showing all 9 stages triggered on push to main.

![Pipeline Overview](docs/screenshots/05-pipeline-running.png)

---

### 06 · Pipeline Complete — All Stages Green
> Full pipeline run completed successfully. All security gates passed. Total runtime ~8 minutes.

![Pipeline All Green](docs/screenshots/06-pipeline-all-green.png)

---

### 07 · Stage 2 — Bandit SAST Scan Output
> Bandit scanned the Python application source. Results uploaded to GitHub Security tab as SARIF.

![Bandit SAST](docs/screenshots/07-sast-bandit-logs.png)

```
Test results:
  No issues identified.
Code scanned:
  Total lines of code: 24
  Total lines skipped (#nosec): 0
```

---

### 08 · Stage 6 — Trivy Container Scan
> Trivy scanned the Docker image for CVEs in OS packages and Python dependencies.

![Trivy Scan](docs/screenshots/08-trivy-container-scan.png)

```
dotweb-app (debian 12.x)
Total: 0 (CRITICAL: 0, HIGH: 0)
```

---

### 09 · GitHub Security Tab — SARIF Findings
> Code scanning results from Bandit, Semgrep, Trivy, and tfsec aggregated in GitHub's Security tab.

![GitHub Security Tab](docs/screenshots/09-github-security-tab.png)

---

### 10 · AWS ECR — Repository with Scanned Image
> Docker image pushed to ECR with immutable SHA tag. ECR native scan status shows complete.

![AWS ECR](docs/screenshots/10-aws-ecr-repo.png)

---

### 11 · AWS S3 — Security Reports Bucket
> Consolidated security report uploaded to encrypted S3 bucket after pipeline run 6.

![AWS S3 Reports](docs/screenshots/11-aws-s3-reports.png)

```
reports/6-5712fe2fd4be2f27abb4d1a96aaa32fbfe66c2df.md
```

---

### 12 · AWS IAM — GitHub OIDC Provider
> GitHub Actions OIDC provider registered in AWS IAM. No access keys stored anywhere.

![AWS IAM OIDC](docs/screenshots/12-aws-iam-oidc.png)

```
Provider URL: token.actions.githubusercontent.com
Audience:     sts.amazonaws.com
```

---

### 13 · Terraform Destroy — Clean Teardown
> All AWS resources destroyed cleanly. Zero residual infrastructure. Free Tier confirmed.

![Terraform Destroy](docs/screenshots/13-terraform-destroy.png)

```
Destroy complete! Resources: 8 destroyed.
```

---

## 📁 Project Structure

```
dotweb-devsecops-pipeline/
│
├── .github/
│   └── workflows/
│       └── devsecops-pipeline.yml     # 9-stage CI/CD security pipeline
│
├── app/
│   ├── app.py                         # Flask application (pipeline scan target)
│   ├── requirements.txt               # Python dependencies
│   └── Dockerfile                     # Multi-stage Docker build
│
├── terraform/
│   ├── main.tf                        # Provider and Terraform version config
│   ├── variables.tf                   # All input variables
│   ├── resources.tf                   # ECR, S3, IAM, OIDC resource definitions
│   ├── outputs.tf                     # Terraform output values
│   └── terraform.tfvars.example       # Variable template
│
├── docs/
│   └── screenshots/                   # Pipeline documentation screenshots
│
├── .gitignore
└── README.md
```

---

## ⚡ Quick Start

### Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Git | Any |
| Terraform | ≥ 1.3.0 |
| AWS CLI | ≥ 2.0 |
| Docker | Any |
| Python | ≥ 3.10 |

### Deployment

```bash
# 1. Clone the repository
git clone https://github.com/AdeoyeEmmanuel2020/dotweb-devsecops-pipeline.git
cd dotweb-devsecops-pipeline

# 2. Configure AWS credentials
aws configure
aws sts get-caller-identity

# 3. Set Terraform variables
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set github_org to your GitHub username

# 4. Provision AWS infrastructure
terraform init
terraform plan
terraform apply

# 5. Add GitHub repository secrets
# AWS_ROLE_ARN     = terraform output iam_role_arn
# S3_REPORTS_BUCKET = terraform output s3_reports_bucket
# AWS_REGION       = us-east-1

# 6. Push to trigger pipeline
cd ..
git push origin main
```

### Teardown

```bash
cd terraform
terraform destroy
```

---

## Configuration Reference

### Terraform Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region for all resources |
| `environment` | `dev` | Environment tag |
| `project_name` | `dotweb-devsecops` | Resource name prefix |
| `ecr_repo_name` | `dotweb-app` | ECR repository name |
| `pipeline_bucket_suffix` | `pipeline-reports` | S3 bucket name suffix |
| `github_org` | — | **Required.** Your GitHub username |
| `github_repo` | `dotweb-devsecops-pipeline` | GitHub repository name |
| `create_oidc_provider` | `true` | Set to `false` if OIDC provider already exists |

### GitHub Secrets Required

| Secret | Source | Example |
|--------|--------|---------|
| `AWS_ROLE_ARN` | `terraform output iam_role_arn` | `arn:aws:iam::123456789012:role/dotweb-devsecops-github-actions-role` |
| `S3_REPORTS_BUCKET` | `terraform output s3_reports_bucket` | `dotweb-devsecops-pipeline-reports-123456789012` |
| `AWS_REGION` | Hardcoded | `us-east-1` |

---

## Security Design Decisions

**Keyless Authentication** — The pipeline never stores AWS access keys. GitHub's OIDC provider issues short-lived tokens per job. The IAM role's trust policy restricts assumption to this specific repository only.

**IMMUTABLE ECR Tags** — Container image tags cannot be overwritten after push. This prevents supply chain attacks where a compromised image could silently replace a verified one.

**Shift-Left Security** — Secrets scanning and SAST run before the Docker build stage. A developer receives security feedback within 2 minutes of pushing code, before any build or deployment resources are consumed.

**Defence in Depth** — Container images are scanned twice — by Trivy before push and by AWS ECR's native scanner after push. Two independent tools with different vulnerability databases provide broader coverage.

**Encrypted Audit Trail** — All scan reports are stored in S3 with AES-256 server-side encryption, versioning enabled, and all public access blocked. Reports are retained for 30 days then automatically expired to control storage costs.

---

## Pipeline Metrics

| Metric | Value |
|--------|-------|
| Total pipeline stages | 9 |
| Security tools integrated | 8 |
| Average pipeline runtime | ~8 minutes |
| Vulnerabilities caught pre-production | 100% automated |
| AWS access keys stored | 0 |
| Manual security review steps | 0 |
| SARIF reports to GitHub Security | 4 (Bandit, Semgrep, Trivy, tfsec) |
| Audit report retention | 30 days |

---

## Author

**Your Name**

Cloud Infrastructure Engineer | AWS | Terraform | Security

[GitHub](https://github.com/AdeoyeEmmanuel2020) ·
[LinkedIn](https://www.linkedin.com/in/emmanuel-adeoye-29187bb7/)

---

## License

MIT License — free to use, modify, and distribute with attribution.
