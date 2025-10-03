# GitHub Actions Setup and Troubleshooting

This document provides setup instructions and troubleshooting guidance for the GitHub Actions workflows in this repository.

## Required Repository Settings

### 1. Branch Protection Rules
Navigate to Settings → Branches → Add rule for `main`:

```yaml
Branch protection rules for 'main':
- Require pull request reviews: ✅
- Require status checks: ✅
  - Security Scan
  - Lint and Format  
  - Validate Terraform
  - Run Tests
- Require branches to be up to date: ✅
- Include administrators: ✅
- Allow force pushes: ❌
- Allow deletions: ❌
```

### 2. Actions Permissions
Navigate to Settings → Actions → General:

```yaml
Actions permissions:
- Allow all actions and reusable workflows: ✅
- Read and write permissions: ✅
- Allow GitHub Actions to create and approve pull requests: ✅
```

### 3. Security Settings
Navigate to Settings → Security → Code scanning:

```yaml
Code scanning alerts: ✅ Enabled
Dependency alerts: ✅ Enabled
Secret scanning: ✅ Enabled
```

## Required Secrets

### Azure Credentials
Create a service principal and add as repository secret:

```bash
# Create service principal
az ad sp create-for-rbac --name "terraform-github-actions" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth

# Add output as AZURE_CREDENTIALS secret
```

### Optional Secrets
- `SEMGREP_APP_TOKEN`: For enhanced Semgrep security scanning
- `GITHUB_TOKEN`: Automatically available (no setup needed)

## Common Issues and Solutions

### 1. SARIF Upload Failures
**Error**: `Path does not exist: reports/results.sarif`

**Solution**: Fixed in updated workflows with:
- Automatic reports directory creation
- Conditional SARIF uploads (only when files exist)
- Proper error handling

### 2. Git Push Failures  
**Error**: `fatal: unable to access 'https://github.com/...': The requested URL returned error: 403`

**Causes**:
- Fork repository (limited write access)
- Insufficient GitHub token permissions
- Branch protection rules blocking pushes

**Solutions**:
- Updated workflows use `github-actions[bot]` identity
- Added graceful failure handling
- Disabled auto-push in favor of manual control
- Added proper permissions to workflow jobs

### 3. CodeQL Integration Issues
**Error**: `Resource not accessible by integration`

**Solution**: Updated workflows with proper permissions:
```yaml
permissions:
  security-events: write
  contents: read
  actions: read
  id-token: write
```

### 4. Terraform Backend Issues
**Error**: Backend configuration errors during CI

**Solution**: All validation workflows use `-backend=false` flag to avoid state conflicts

### 5. Documentation Generation Issues
**Error**: terraform-docs push failures

**Solution**: 
- Separated documentation generation from automatic pushing
- Added conditional logic for changes detection
- Improved error handling for permission issues

## Workflow Behavior by Event

### Push to Main
- ✅ Full security scan
- ✅ Terraform validation
- ✅ Documentation generation
- ✅ Progressive deployment (if configured)

### Pull Request
- ✅ Security scan on changed files
- ✅ Terraform validation
- ✅ PR comments with results
- ❌ No deployment or documentation updates

### Daily Schedule (2 AM UTC)
- ✅ Comprehensive security scan
- ✅ Dependency vulnerability check
- ✅ Report generation

### Manual Trigger
- ✅ All workflows available for manual execution
- ✅ Full validation and testing

## Environment-Specific Configuration

### Development
- Automatic deployment on main branch push
- Relaxed security scanning (soft_fail: true)
- Fast feedback loops

### Staging  
- Requires manual approval
- Full security validation
- Integration testing

### Production
- Requires admin approval
- Mandatory security clearance
- Wait timer for review
- Full audit trail

## Monitoring and Alerts

### Workflow Status
Monitor in repository's Actions tab:
- Green checkmarks: All validations passed
- Red X marks: Issues found, review logs
- Yellow indicators: Warnings or manual approval needed

### Security Findings
Review in repository's Security tab:
- Code scanning alerts
- Dependency vulnerabilities  
- Secret scanning results

### Notifications
Configure in personal Settings → Notifications:
- Workflow failures
- Security alerts
- Pull request status

## Best Practices

### For Contributors
1. **Local Validation**: Run `./scripts/validate-terraform.sh` before committing
2. **Small PRs**: Keep changes focused for faster reviews
3. **Security First**: Address security findings promptly
4. **Documentation**: Update docs when adding/changing infrastructure

### For Maintainers
1. **Regular Reviews**: Check security tab weekly
2. **Update Dependencies**: Keep actions and tools current
3. **Permission Audits**: Review access quarterly
4. **Backup Strategy**: Ensure state files are backed up

### For DevOps Teams
1. **Environment Parity**: Keep dev/staging/prod similar
2. **Secret Rotation**: Rotate service principals regularly
3. **Monitoring**: Set up alerts for critical failures
4. **Compliance**: Ensure workflows meet organizational standards

## Troubleshooting Commands

### Local Testing
```bash
# Validate all configurations
./scripts/validate-terraform.sh

# Test specific environment
cd environments/dev && terraform validate

# Check formatting
terraform fmt -check -recursive

# Run security scan locally (if tools installed)
checkov -d . --framework terraform
```

### GitHub Actions Debugging
```bash
# Enable debug logging in workflow
ACTIONS_STEP_DEBUG: true
ACTIONS_RUNNER_DEBUG: true

# Check workflow logs
gh run list --workflow="Terraform CI/CD Pipeline"
gh run view [RUN_ID]
```

### Permission Issues
```bash
# Check repository permissions
gh api repos/:owner/:repo/collaborators/:username

# Verify branch protection
gh api repos/:owner/:repo/branches/main/protection
```

## Getting Help

1. **Check this documentation** for common issues
2. **Review workflow logs** in Actions tab
3. **Check Security tab** for security-related issues
4. **Create an issue** with:
   - Workflow name and run ID
   - Error message
   - Expected vs actual behavior
5. **Contact DevOps team** for urgent production issues

## Updates and Maintenance

This setup is designed to be:
- **Self-maintaining**: Automatic dependency updates where possible
- **Extensible**: Easy to add new environments or tools
- **Configurable**: Adjustable security and validation rules
- **Documented**: Comprehensive guides and troubleshooting

Regular maintenance tasks:
- [ ] Monthly: Review and update tool versions
- [ ] Quarterly: Audit permissions and access
- [ ] Annually: Review and update security policies
- [ ] As needed: Update workflows for new requirements