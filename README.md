# Terraform Lab 🏗️

[![Terraform CI/CD](https://github.com/Dvdsluis/tflab/actions/workflows/terraform-ci-cd.yml/badge.svg)](https://github.com/Dvdsluis/tflab/actions/workflows/terraform-ci-cd.yml)
[![Security Scan](https://github.com/Dvdsluis/tflab/actions/workflows/security-scan.yml/badge.svg)](https://github.com/Dvdsluis/tflab/actions/workflows/security-scan.yml)
[![Documentation](https://github.com/Dvdsluis/tflab/actions/workflows/terraform-docs.yml/badge.svg)](https://github.com/Dvdsluis/tflab/actions/workflows/terraform-docs.yml)

A comprehensive Terraform learning lab with CI/CD pipelines, security scanning, and automated documentation generation.

## 🚀 Features

- **Multi-Environment Setup**: Progressive deployment across dev, staging, and production
- **Modular Architecture**: Reusable modules for networking, compute, and database resources
- **Automated Testing**: Integration with Terratest for infrastructure testing
- **Security Scanning**: Multiple security scanners (Trivy, Checkov, TFSec, Semgrep)
- **CI/CD Pipelines**: Comprehensive GitHub Actions workflows
- **Documentation**: Auto-generated documentation with terraform-docs
- **Code Quality**: TFLint integration with Azure-specific rules

## 🏗️ Architecture

```
├── environments/          # Environment-specific configurations
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment
│   └── prod/              # Production environment
├── modules/               # Reusable Terraform modules
│   ├── networking/        # VNet, subnets, security groups
│   ├── compute/          # Virtual machines, scale sets
│   └── database/         # Azure SQL, storage accounts
├── tests/                # Terratest and Terraform test files
├── examples/             # Usage examples
└── scripts/              # Utility scripts
```

## 🛠️ Prerequisites

- [Terraform](https://terraform.io/downloads.html) >= 1.13.3
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [terraform-docs](https://terraform-docs.io/) >= 0.18.0
- [TFLint](https://github.com/terraform-linters/tflint) >= 0.48.0
- [Go](https://golang.org/dl/) >= 1.21 (for Terratest)

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/Dvdsluis/tflab.git
cd tflab

# Install dependencies (if not already installed)
./scripts/install-tools.sh
```

### 2. Configure Azure Authentication
```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"

# Create service principal for Terraform
az ad sp create-for-rbac --name "terraform-sp" \
  --role contributor \
  --scopes /subscriptions/your-subscription-id
```

### 3. Initialize and Deploy Development Environment
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## 📋 GitHub Actions Workflows

### Main CI/CD Pipeline (`terraform-ci-cd.yml`)
Comprehensive pipeline that includes:
- 🔒 Security scanning (Trivy, Checkov)
- 🔍 Code linting and formatting
- ✅ Terraform validation
- 🧪 Automated testing
- 📋 Progressive deployment (dev → staging → prod)
- 📚 Documentation generation

### PR Validation (`terraform-pr-validation.yml`)
Fast feedback for pull requests:
- Validates only changed files
- Comments on PRs with results
- Security scanning for changed code

### Documentation (`terraform-docs.yml`)
Automatic documentation generation:
- Updates README files for modules
- Maintains up-to-date documentation

### Security Scanning (`security-scan.yml`)
Comprehensive security analysis:
- Multiple scanners (Trivy, Checkov, TFSec, Semgrep)
- Daily scheduled scans
- SARIF upload to GitHub Security tab

## 🔧 Configuration

### Required GitHub Secrets
- `AZURE_CREDENTIALS`: Azure service principal credentials (JSON format)
- `SEMGREP_APP_TOKEN`: Optional, for enhanced Semgrep scanning

### Environment Protection Rules
Configure in GitHub Settings → Environments:
- **dev**: Auto-deploy on main branch
- **staging**: Require review from team leads
- **production**: Require review + wait timer

## 🧪 Testing

### Run Terraform Native Tests
```bash
cd tests
terraform test
```

### Run Terratest (Go-based tests)
```bash
cd tests
go mod init terratest
go mod tidy
go test -v -timeout 30m
```

### Local Validation
```bash
# Format code
terraform fmt -recursive

# Initialize TFLint
tflint --init

# Run TFLint
tflint

# Validate configurations
terraform validate
```

## 📚 Documentation

- [Workflows Setup Guide](.github/WORKFLOWS_README.md)
- [Learning Guide](LEARNING_GUIDE.md)
- [Module Documentation](modules/README.md)

### Auto-Generated Documentation
Documentation is automatically generated using terraform-docs:
- Module READMEs are updated on every push to main
- Include Terraform docs markers in your README files:

```markdown
<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

No requirements.

## Providers

## Providers

No providers.

## Modules

## Modules

No modules.

## Resources

## Resources

No resources.

## Inputs

## Inputs

No inputs.

## Outputs

## Outputs

No outputs.

<!-- END_TF_DOCS -->
```

## 🔒 Security

This project includes comprehensive security scanning:
- **Trivy**: Vulnerability scanning for dependencies and containers
- **Checkov**: Infrastructure as Code security scanning
- **TFSec**: Terraform-specific security rules
- **Semgrep**: Static analysis for security patterns

View security findings in the repository's Security tab.

## 📈 Monitoring

### Workflow Status
Monitor workflow runs in the Actions tab:
- ✅ All checks passing: Safe to merge
- ❌ Failed checks: Review logs and fix issues
- 🟡 Pending: Waiting for approval or in progress

### Security Alerts
- Enable GitHub security features
- Review Security tab regularly
- Address high/critical findings promptly

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes
4. Run local validation: `terraform fmt && terraform validate`
5. Commit changes: `git commit -am 'Add new feature'`
6. Push to branch: `git push origin feature/new-feature`
7. Create a Pull Request

### Code Standards
- Follow Terraform best practices
- Use snake_case for resource names
- Include proper variable descriptions
- Add appropriate tags to resources
- Write tests for new modules

## 📖 Learning Resources

- [Terraform Documentation](https://terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [Learning Guide](LEARNING_GUIDE.md)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## �� Support

- 📖 Check the [documentation](.github/WORKFLOWS_README.md)
- 🐛 Create an [issue](https://github.com/Dvdsluis/tflab/issues)
- 💬 Start a [discussion](https://github.com/Dvdsluis/tflab/discussions)

---

**Happy Infrastructure Coding! 🚀**
