# GitHub Actions Setup Guide

This repository includes comprehensive GitHub Actions workflows for Terraform CI/CD, security scanning, and documentation generation.

## Workflows Overview

### 1. `terraform-ci-cd.yml` - Main CI/CD Pipeline
**Triggers:** Push to main/develop, Pull Requests to main
**Features:**
- 🔒 Security scanning (Trivy, Checkov)
- 🔍 Code linting (TFLint, Terraform fmt)
- ✅ Terraform validation across all environments
- 🧪 Automated testing (Terratest/Terraform native tests)
- 📋 Progressive deployment (dev → staging → prod)
- 📚 Automatic documentation generation

### 2. `terraform-pr-validation.yml` - PR Validation
**Triggers:** Pull Requests to main
**Features:**
- 🎯 Validates only changed files
- 💬 Comments on PRs with validation results
- ⚡ Fast feedback for developers

### 3. `terraform-docs.yml` - Documentation Generation
**Triggers:** Push to main, Manual trigger
**Features:**
- 📖 Generates README.md for modules and environments
- 🔄 Auto-commits documentation updates

### 4. `security-scan.yml` - Security Analysis
**Triggers:** Push, PRs, Daily schedule, Manual
**Features:**
- 🛡️ Multiple security scanners (Trivy, Checkov, TFSec, Semgrep)
- 📊 SARIF upload to GitHub Security tab
- 📦 Dependency vulnerability checking

## Required Secrets

Add these secrets to your GitHub repository:

### Azure Authentication
```bash
# Create Azure Service Principal
az ad sp create-for-rbac --name "github-actions-terraform" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth
```

Add the output as `AZURE_CREDENTIALS` secret:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "..."
}
```

### Optional Secrets
- `SEMGREP_APP_TOKEN` - For enhanced Semgrep scanning
- `GITHUB_TOKEN` - Usually available by default

## Environment Protection Rules

Set up environment protection rules in GitHub:

1. Go to Settings → Environments
2. Create environments: `dev`, `staging`, `production`
3. Configure protection rules:
   - **dev**: Auto-deploy on main branch
   - **staging**: Require review from team leads
   - **production**: Require review from admins + wait timer

## Repository Settings

### Branch Protection
Enable branch protection for `main`:
- Require PR reviews
- Require status checks to pass
- Include administrators
- Required status checks:
  - `Security Scan`
  - `Lint and Format`
  - `Validate Terraform`
  - `Run Tests`

### Security Settings
1. Enable GitHub Security features:
   - Dependency graph
   - Dependabot alerts
   - Code scanning alerts
   - Secret scanning

2. Configure SARIF uploads in Security tab

## Terraform Backend Configuration

Update your Terraform configurations to use remote backends:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate${random_id.storage_account.hex}"
    container_name       = "tfstate"
    key                  = "${var.environment}/terraform.tfstate"
  }
}
```

## Local Development

### Prerequisites
Install required tools:
```bash
# Terraform
terraform --version

# TFLint
tflint --version

# terraform-docs
terraform-docs --version

# Azure CLI
az --version
```

### Pre-commit Hooks (Optional)
Install pre-commit hooks for local validation:

```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << EOF
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: checkov
EOF

# Install hooks
pre-commit install
```

## Workflow Customization

### Environment Variables
Customize versions in workflow files:
```yaml
env:
  TF_VERSION: "1.13.3"
  TFLINT_VERSION: "v0.48.0"
  TERRAFORM_DOCS_VERSION: "v0.18.0"
```

### Adding New Environments
1. Create new environment directory: `environments/new-env/`
2. Add environment protection rules in GitHub
3. Update workflow matrix to include new environment

### Custom TFLint Rules
Modify `.tflint.hcl` to customize linting rules:
```hcl
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
```

## Monitoring and Troubleshooting

### Workflow Logs
- View workflow runs in Actions tab
- Download artifacts for detailed logs
- Check Security tab for scan results

### Common Issues
1. **Authentication failures**: Check AZURE_CREDENTIALS secret
2. **TFLint errors**: Review .tflint.hcl configuration
3. **Test failures**: Check Terratest setup in tests/ directory
4. **Documentation not updating**: Verify terraform-docs configuration

### Notifications
Configure notifications in GitHub Settings → Notifications for:
- Failed workflow runs
- Security alerts
- Dependency vulnerabilities

## Best Practices

1. **Small PRs**: Keep changes small for faster validation
2. **Test locally**: Run terraform fmt, validate, and plan locally
3. **Security first**: Address security findings promptly
4. **Documentation**: Keep module documentation up to date
5. **Environment parity**: Keep environments as similar as possible
6. **State management**: Use remote state with state locking
7. **Secrets**: Never commit secrets or sensitive data

## Support

For issues with the workflows:
1. Check workflow logs in Actions tab
2. Review this documentation
3. Check Terraform and tool documentation
4. Create an issue in the repository