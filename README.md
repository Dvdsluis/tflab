# Terraform Lab

[![Terraform CI/CD](https://github.com/Dvdsluis/tflab/workflows/Terraform%20CI/CD%20Pipeline/badge.svg)](https://github.com/Dvdsluis/tflab/actions)

A comprehensive Terraform laboratory for learning Infrastructure as Code with Azure, featuring enterprise-grade CI/CD pipelines, security scanning, and automated documentation.

## Features

- **Multi-environment setup**: Dev, Staging, and Production environments
- **Modular architecture**: Reusable networking, compute, and database modules  
- **Enterprise security**: Hardened modules with SSH-only access and security scanning
- **Automated testing**: Native Terraform tests and Terratest integration
- **CI/CD pipeline**: GitHub Actions with automated validation, security scans, and deployment
- **Documentation**: Auto-generated module documentation with terraform-docs

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Dvdsluis/tflab.git
   cd tflab
   ```

2. **Initialize Terraform** (choose an environment):
   ```bash
   cd environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

3. **Run tests**:
   ```bash
   cd tests
   terraform test
   ```

## Project Structure

```
├── environments/          # Environment-specific configurations
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment
│   └── prod/              # Production environment
├── modules/               # Reusable Terraform modules
│   ├── networking/        # VNet, subnets, NSGs
│   ├── compute/           # VM Scale Sets, Load Balancers
│   └── database/          # PostgreSQL/MySQL with Key Vault
├── tests/                 # Terraform native tests
├── .github/workflows/     # CI/CD pipelines
└── scripts/               # Utility scripts
```

## Modules

### Networking Module
- Virtual Network (VNet) with configurable CIDR
- Public, private, and database subnets
- Network Security Groups (NSGs) with security rules
- Public IP addresses

### Compute Module
- VM Scale Sets for web and application tiers
- Load balancers with health probes
- SSH key-based authentication (no password auth)
- Auto-scaling capabilities

### Database Module
- PostgreSQL or MySQL Flexible Server
- Azure Key Vault for secrets management
- Network integration with database subnets
- Backup and high availability options

## Environment Configuration

Each environment (dev/staging/prod) includes:
- Environment-specific variable values
- Terraform state configuration
- Resource naming conventions
- Scaling configurations

## Security Features

- **SSH-only access**: Password authentication disabled
- **Security scanning**: Trivy, Checkov, and Semgrep integration
- **Secrets management**: Azure Key Vault for database credentials
- **Network security**: NSGs with least-privilege rules
- **Resource hardening**: Enterprise security best practices

## CI/CD Pipeline

The GitHub Actions pipeline includes:

1. **Security Scan**: Vulnerability and compliance scanning
2. **Lint and Format**: Code quality checks
3. **Validate**: Terraform validation across environments
4. **Test**: Automated testing with Terraform native tests
5. **Plan**: Generate deployment plans for review
6. **Deploy**: Automated deployment with approval gates
7. **Documentation**: Auto-update module documentation

## Testing

The project includes comprehensive testing:

- **Unit tests**: Individual module testing
- **Integration tests**: Full environment testing
- **Security tests**: Configuration compliance
- **Documentation tests**: README and module docs validation

Run tests locally:
```bash
cd tests
terraform init
terraform test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and formatting
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions and support:
- Create an issue in this repository
- Review the examples in the `examples/` directory
- Check the module documentation in each module's README

---

**Note**: This is a learning laboratory. Ensure you understand the costs associated with Azure resources before deploying to production environments.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be automatically updated by terraform-docs -->
<!-- END_TF_DOCS -->
