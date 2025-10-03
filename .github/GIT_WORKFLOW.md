# Git Workflow and File Management Guide

## Overview
This document outlines the Git workflow, file management practices, and security considerations for the Terraform lab repository.

## File Exclusion Strategy

### Sensitive Files (.gitignore)
The following files are excluded from version control to prevent security breaches and maintain environment isolation:

#### Terraform State Files
```
*.tfstate
*.tfstate.*
```
**Rationale**: State files contain sensitive information including resource IDs, IP addresses, and potentially secrets. They also contain provider-specific implementation details that should remain local or in remote state storage.

#### Variable Files
```
*.tfvars
*.tfvars.json
```
**Rationale**: Variable files often contain environment-specific secrets, connection strings, and configuration that differs between deployments. Committing these would expose sensitive data and create deployment conflicts.

#### Terraform Directories
```
.terraform/
```
**Rationale**: Contains provider binaries and cached modules that are environment-specific and can be regenerated. Including these would bloat the repository and cause platform-specific issues.

#### Plan Files
```
*.tfplan
```
**Rationale**: Plan files may contain sensitive information and are temporary artifacts of the planning process. They should not be persisted in version control.

### Configuration Management

#### Lock Files (Committed)
```
.terraform.lock.hcl
```
**Rationale**: Lock files ensure consistent provider versions across environments and team members. These should be committed to maintain reproducible builds.

#### Example Files (Committed)
```
terraform.tfvars.example
```
**Rationale**: Example files provide templates for required variables without exposing actual values. They serve as documentation and starting points for new environments.

## Workflow Process

### 1. Initial Setup
```bash
# Clone repository
git clone <repository-url>
cd tflab

# Copy example variables
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars

# Customize variables for your environment
vim environments/dev/terraform.tfvars
```

### 2. Development Workflow
```bash
# Create feature branch
git checkout -b feature/infrastructure-update

# Make changes to .tf files
# Update documentation if needed

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Check what files will be committed
git status

# Stage only tracked files (excludes .gitignore items)
git add .

# Commit with descriptive message
git commit -m "feat: add monitoring configuration for web tier"
```

### 3. Pre-commit Validation
Before committing, ensure:
- No sensitive files are staged
- Code is formatted (`terraform fmt`)
- Configuration is valid (`terraform validate`)
- Documentation is updated

### 4. Remote State Management
```bash
# Initialize with remote backend
terraform init

# Migrate local state to remote (if needed)
terraform init -migrate-state
```

## Security Considerations

### Environment Isolation
Each environment (dev/staging/prod) should:
- Use separate Azure subscriptions or resource groups
- Have distinct CIDR blocks to prevent network conflicts
- Use environment-specific service principals
- Maintain separate state storage

### Access Control
- Repository access limited to authorized team members
- Environment-specific deployment permissions
- Service principal rotation schedule
- Regular access audits

### Secret Management
- Use Azure Key Vault for runtime secrets
- Environment variables for CI/CD secrets
- No hardcoded credentials in any files
- Separate .tfvars files per environment (not committed)

## Troubleshooting

### Accidentally Committed Sensitive Files
```bash
# Remove from Git history but keep locally
git rm --cached path/to/sensitive/file

# Commit the removal
git commit -m "security: remove sensitive file from tracking"

# Force push to rewrite history (use with caution)
git push --force-with-lease
```

### State File Issues
```bash
# If state becomes corrupted or locked
terraform force-unlock LOCK_ID

# Import existing resources if state is lost
terraform import resource_type.name resource_id
```

### Provider Issues
```bash
# Clear provider cache
rm -rf .terraform/

# Reinitialize
terraform init
```

## Best Practices

### Code Organization
- Keep modules focused and reusable
- Use consistent naming conventions
- Document all variables and outputs
- Implement proper resource tagging

### Version Control
- Small, focused commits
- Descriptive commit messages
- Regular branch cleanup
- Protected main branch with required reviews

### Testing
- Validate changes locally before committing
- Use Terratest for integration testing
- Test in dev environment before promoting
- Implement automated testing in CI/CD

### Documentation
- Keep README files current
- Document infrastructure decisions
- Maintain change logs
- Update .tfvars.example files when adding variables

## CI/CD Integration

### GitHub Actions Workflow
The repository includes automated workflows that:
- Validate Terraform syntax and formatting
- Run security scans on infrastructure code
- Test deployments in isolated environments
- Generate and update documentation
- Enforce approval processes for production

### Environment Promotion
```
dev → staging → production
```
Each promotion requires:
- Successful automated testing
- Code review approval
- Security scan clearance
- Infrastructure validation

This systematic approach ensures code quality, security compliance, and operational reliability across all environments.