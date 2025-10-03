# Terraform Lab Learning Guide

Welcome to your comprehensive Terraform lab! This guide will walk you through learning advanced Terraform concepts hands-on.

## 🎯 Learning Objectives

By completing this lab, you'll master:

1. **Module Architecture**: Root and child module composition patterns
2. **Variable Inheritance**: How data flows between modules
3. **Infrastructure Testing**: Automated testing with Terratest
4. **Documentation**: Auto-generating docs with terraform-docs
5. **Multi-Environment**: Managing dev, staging, and production environments
6. **Best Practices**: Security, tagging, and organizational patterns

## 📚 Prerequisites

### Required Tools
```bash
# Terraform
terraform --version  # Should be >= 1.0

# Go (for Terratest)
go version  # Should be >= 1.19

# Azure CLI (configured)
az --version
az account list

# terraform-docs (for documentation)
terraform-docs --version

# Optional but recommended
tflint --version  # For linting
```

### Azure Setup
- Azure subscription with appropriate permissions
- Azure CLI configured with credentials
- Ability to create VNet, VM, Azure Database resources

## 🚀 Getting Started

### Phase 1: Explore the Structure (15 minutes)

1. **Understand the project layout**:
   ```bash
   # View the overall structure
   tree .
   
   # Or on Windows:
   dir /s
   ```

2. **Examine the modules**:
   - `modules/networking/` - VPC, subnets, routing
   - `modules/compute/` - EC2, Auto Scaling, Load Balancers
   - `modules/database/` - RDS with security and monitoring

3. **Review environments**:
   - `environments/dev/` - Development configuration
   - `environments/staging/` - Staging with higher capacity
   - `environments/prod/` - Production with all features

### Phase 2: Run the Basic Example (20 minutes)

Start with the simplest configuration:

```bash
# Navigate to basic example
cd examples/basic

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply (if comfortable with AWS costs)
terraform apply

# Get outputs
terraform output

# Clean up
terraform destroy
```

**Learning Focus**: 
- How modules are called
- Variable passing
- Output usage
- Basic infrastructure patterns

### Phase 3: Development Environment (30 minutes)

Deploy the full development environment:

```bash
cd environments/dev

# Initialize
terraform init

# Plan and review
terraform plan

# Apply
terraform apply

# Test the infrastructure
curl http://$(terraform output -raw web_load_balancer_dns)

# Clean up when done
terraform destroy
```

**Learning Focus**:
- Complex module composition
- Multiple resource types
- Security group relationships
- Output referencing between modules

### Phase 4: Module Testing (25 minutes)

Learn infrastructure testing:

```bash
cd tests

# Install Go dependencies
go mod tidy

# Run individual module tests
go test -v -run TestNetworkingModule

# Run full environment tests (takes longer)
go test -v -run TestTerraformDevEnvironment

# Run all tests
go test -v
```

**Learning Focus**:
- Infrastructure testing patterns
- Validation techniques
- Test organization
- Terratest framework usage

### Phase 5: Documentation Generation (10 minutes)

Generate and explore documentation:

```bash
# Run documentation generation
./scripts/generate-docs.sh
# or on Windows:
.\scripts\generate-docs.bat

# Explore generated docs
cat modules/networking/README.md
cat docs/networking.md
```

**Learning Focus**:
- Automated documentation
- Variable documentation
- Output documentation
- Module usage examples

### Phase 6: Multi-Environment Patterns (30 minutes)

Compare environment configurations:

```bash
# Compare variable files
diff environments/dev/variables.tf environments/staging/variables.tf
diff environments/staging/variables.tf environments/prod/variables.tf

# Notice patterns in main.tf files
code environments/dev/main.tf environments/staging/main.tf
```

**Learning Focus**:
- Environment-specific variables
- Configuration inheritance
- Resource scaling patterns
- Security progressions

## 🎨 Advanced Exercises

### Exercise 1: Add a New Module
Create a `modules/monitoring/` module that adds:
- CloudWatch dashboards
- SNS topics for alerts
- CloudWatch alarms for key metrics

### Exercise 2: Extend an Environment
Add to the staging environment:
- WAF for the load balancer
- S3 bucket for application assets
- ElastiCache cluster

### Exercise 3: Create Custom Tests
Add tests for:
- Security group rules validation
- Database encryption verification
- Load balancer health checks

### Exercise 4: Documentation Enhancement
Enhance documentation with:
- Architecture diagrams (using mermaid)
- Cost estimates
- Security considerations

## 🔍 Key Patterns to Notice

### 1. Variable Flow
```
Environment variables.tf
    ↓
Environment main.tf
    ↓
Module variables.tf
    ↓
Module resources
```

### 2. Output Composition
```
Module outputs.tf
    ↓
Environment main.tf (module references)
    ↓
Environment outputs.tf
```

### 3. Resource Dependencies
```
Networking Module
    ↓
Compute Module (depends on networking)
    ↓
Database Module (depends on compute for security groups)
```

### 4. Progressive Complexity
- **Dev**: Minimal resources, cost-optimized
- **Staging**: Production-like, with read replicas
- **Prod**: Full features, high availability, security

## 🛡️ Security Best Practices Demonstrated

1. **Network Isolation**: Separate subnets for different tiers
2. **Security Groups**: Least privilege access rules
3. **Database Security**: Encrypted storage, private subnets
4. **Secrets Management**: AWS Secrets Manager for passwords
5. **Tagging**: Consistent resource tagging strategy

## 📊 Cost Management Tips

1. **Instance Sizing**: Start with t3.micro for learning
2. **NAT Gateways**: Disable in dev to save costs
3. **RDS**: Use db.t3.micro for development
4. **Auto Scaling**: Set min/desired to 0 for testing
5. **Clean Up**: Always run `terraform destroy` after learning

## 🐛 Troubleshooting

### Common Issues

1. **AWS Permissions**: Ensure your AWS credentials have necessary permissions
2. **Region Availability**: Some instance types aren't available in all regions
3. **Resource Limits**: Check AWS service quotas
4. **State Locking**: Use S3 backend with DynamoDB for team environments

### Debugging Commands
```bash
# Verbose terraform output
TF_LOG=INFO terraform plan

# Check AWS credentials
aws sts get-caller-identity

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

## 🎓 Next Steps

After mastering this lab:

1. **Advanced Terraform**: Explore workspaces, remote backends
2. **CI/CD Integration**: Add Terraform to GitHub Actions
3. **Security**: Implement Checkov, tfsec for security scanning
4. **State Management**: Learn remote state best practices
5. **Enterprise**: Explore Terraform Cloud/Enterprise features

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [terraform-docs](https://terraform-docs.io/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

Happy learning! 🚀