# Terraform Lab 🚀

[![Terraform](https://img.shields.io/badge/Terraform-%23623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)

## Overview

A comprehensive Terraform learning laboratory featuring **enterprise-grade infrastructure patterns**, **advanced testing strategies**, and **automated CI/CD pipelines** for Azure cloud deployments.

## 🏗️ What You'll Learn

- **Multi-tier Architecture**: Web, application, and database layer separation
- **Advanced Testing**: Real Azure resource validation using Terraform `assert` blocks  
- **CI/CD Integration**: GitHub Actions with security scanning and compliance checks
- **Module Design**: Reusable, well-documented Terraform modules
- **Security Best Practices**: Network segmentation, NSG rules, and compliance validation

## 🏛️ Architecture

The lab implements a **3-tier architecture** on Azure:

### **Networking Layer** (`modules/networking`)
- Virtual Network with multiple subnets (web, app, database)
- NAT Gateway for outbound internet access
- Network Security Groups with tier-specific rules
- Azure Bastion for secure management access

### **Compute Layer** (`modules/compute`) 
- Virtual Machine Scale Sets for auto-scaling
- Application Gateway for load balancing
- Custom user data scripts for application deployment
- SSH key-based authentication

### **Database Layer** (`modules/database`)
- Azure Database for PostgreSQL (Flexible Server)
- Private endpoint connectivity
- Automated backups and point-in-time recovery
- Database firewall rules

## 📁 Repository Structure

```
tflab/
├── 🏢 environments/          # Environment-specific configurations
│   ├── dev/                  # Development environment
│   ├── staging/              # Staging environment  
│   └── prod/                 # Production environment
├── 🧩 modules/               # Reusable Terraform modules
│   ├── networking/           # VNet, subnets, NSGs, NAT Gateway
│   ├── compute/              # VMSS, Application Gateway, VM
│   └── database/             # PostgreSQL Flexible Server
├── 🧪 tests/                 # Advanced Terraform tests
│   ├── *.tftest.hcl         # Unit and integration tests
│   └── advanced-integration/ # Real Azure resource validation
├── 📚 docs/                  # Comprehensive documentation
├── 🔧 scripts/               # Utility scripts
└── 🚀 .github/workflows/     # CI/CD pipelines
```

## 🚀 Quick Start

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions

### Deployment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tflab
   ```

2. **Configure Azure authentication**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

3. **Deploy to development**
   ```bash
   cd environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

## 🧪 Advanced Testing Features

This lab showcases **enterprise-grade testing** that goes beyond basic validation:

### **Real Azure Resource Testing**
- Uses Terraform `assert` blocks with Azure data sources
- Validates actual resource state, not just configuration
- Tests network connectivity and security compliance
- Automated in CI/CD pipeline

### **Multi-Level Testing Strategy**
```bash
# Run unit tests (fast, configuration-focused)
terraform test tests/networking.tftest.hcl

# Run integration tests (real Azure resources)
terraform test tests/advanced-integration.tftest.hcl

# Run all tests
terraform test
```

## 🚀 CI/CD Pipeline

The repository includes a **comprehensive GitHub Actions workflow**:

### **CI Jobs (Continuous Integration)**
- `ci-security-scan`: Security vulnerability scanning (Trivy + Checkov)
- `ci-terraform-validate`: Terraform syntax and configuration validation
- `ci-terraform-test`: Native Terraform testing with Azure integration

### **CD Jobs (Continuous Deployment)**  
- `cd-plan-dev`: Generate deployment plans with PR comments
- `cd-deploy-dev`: Deploy to development environment

### **QA Jobs (Quality Assurance)**
- `qa-advanced-integration-tests`: Advanced resource state validation
- `qa-network-security-validation`: Azure CLI-based security compliance

## 🔧 Utility Scripts

- `scripts/cleanup-resources.sh`: Clean up Azure resources in correct order
- `scripts/generate-docs.sh`: Generate terraform-docs documentation

## 📚 Documentation

- [`docs/ADVANCED_TESTING_STRATEGY.md`](docs/ADVANCED_TESTING_STRATEGY.md): Comprehensive testing guide
- [`docs/CI_CD_WORKFLOW_STRUCTURE.md`](docs/CI_CD_WORKFLOW_STRUCTURE.md): CI/CD pipeline documentation  
- [`docs/REPOSITORY_CLEANUP_SUMMARY.md`](docs/REPOSITORY_CLEANUP_SUMMARY.md): Repository organization details

## 🎯 Learning Outcomes

After completing this lab, you'll understand:

- ✅ **Infrastructure as Code**: Multi-environment Terraform deployments
- ✅ **Testing Strategy**: Real resource validation with Terraform native testing
- ✅ **CI/CD Integration**: Automated testing and deployment pipelines
- ✅ **Security Practices**: Network segmentation and compliance validation
- ✅ **Module Design**: Reusable, well-documented infrastructure components
- ✅ **Azure Architecture**: 3-tier application deployment patterns

## 🎓 Learning Path

### **Beginner**: Start with Basic Concepts
1. Explore the `examples/basic/` directory
2. Deploy a simple infrastructure to understand module interactions
3. Review the generated terraform-docs documentation

### **Intermediate**: Advanced Testing
1. Study `tests/` directory to understand Terraform testing patterns
2. Run unit tests with `terraform test tests/networking.tftest.hcl`
3. Learn about `assert` blocks and data source validation

### **Advanced**: Enterprise Patterns
1. Examine the CI/CD pipeline in `.github/workflows/`
2. Deploy through the full pipeline using pull requests
3. Understand security scanning and compliance validation

## 🔨 Development Workflow

### **Making Changes**
1. Create a feature branch: `git checkout -b feature/your-change`
2. Make your infrastructure changes
3. Run tests locally: `terraform test`
4. Create a pull request - CI/CD will automatically:
   - Validate syntax and configuration
   - Run security scans
   - Generate deployment plans
   - Execute advanced integration tests

### **Documentation Generation**
```bash
# Generate module documentation
./scripts/generate-docs.sh

# Generate docs for specific module
terraform-docs markdown table modules/networking/ > modules/networking/README.md
```

## 🛡️ Security Features

- **Network Segmentation**: Separate subnets for web, app, and database tiers
- **Security Groups**: Restrictive NSG rules with minimal required access
- **Private Endpoints**: Database accessible only from application tier
- **SSH Key Authentication**: No password-based authentication
- **Automated Security Scanning**: Trivy and Checkov integration in CI/CD

## 🌍 Environments

| Environment | Purpose | Auto-Deploy | 
|-------------|---------|-------------|
| **Development** | Feature development and testing | ✅ On `main` branch |
| **Staging** | Pre-production validation | 🔧 Manual trigger |
| **Production** | Live application deployment | 🔧 Manual trigger |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **HashiCorp Terraform** for infrastructure as code capabilities
- **Microsoft Azure** for cloud platform services  
- **GitHub Actions** for CI/CD automation
- **Terraform Testing** community for advanced testing patterns

---

**Ready to build enterprise-grade infrastructure?** 🚀 Start with the development environment and explore the advanced testing features!

