# GitHub Actions Configuration Guide

## Common Issues and Solutions

### 1. SARIF Upload Path Errors

**Issue**: `Error: Path does not exist: reports/results.sarif`

**Solution**: Ensure directories are created before SARIF generation:

```yaml
- name: Create reports directory
  run: mkdir -p reports
  if: always()

- name: Run Checkov action
  uses: bridgecrewio/checkov-action@master
  with:
    directory: .
    quiet: true
    soft_fail: true
    framework: terraform
    output_format: sarif
    output_file_path: reports/results.sarif

- name: Upload Checkov scan results
  uses: github/codeql-action/upload-sarif@v2
  if: always() && hashFiles('reports/results.sarif') != ''
  with:
    sarif_file: reports/results.sarif
```

### 2. Git Push Permission Errors

**Issue**: `remote: Write access to repository not granted.`

**Root Cause**: Default GITHUB_TOKEN has read-only permissions for forked repositories or specific actions.

**Solutions**:

#### Option A: Disable Git Push for Documentation
```yaml
- name: Setup terraform-docs
  uses: terraform-docs/gh-actions@main
  with:
    working-dir: .
    output-file: README.md
    output-method: inject
    git-push: "false"  # Disable automatic push
    git-commit-message: "docs: update terraform documentation"
```

#### Option B: Use Personal Access Token
1. Create Personal Access Token with `repo` scope
2. Add as repository secret: `PAT_TOKEN`
3. Update workflow:
```yaml
- name: Checkout code
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.PAT_TOKEN }}
    fetch-depth: 0
```

#### Option C: Use GitHub App Token
```yaml
- name: Generate token
  id: generate_token
  uses: tibdex/github-app-token@v1
  with:
    app_id: ${{ secrets.APP_ID }}
    private_key: ${{ secrets.APP_PRIVATE_KEY }}

- name: Checkout code
  uses: actions/checkout@v4
  with:
    token: ${{ steps.generate_token.outputs.token }}
```

### 3. Required Permissions for Jobs

**Security Scan Job**:
```yaml
permissions:
  security-events: write
  contents: read
  actions: read
```

**Documentation Job**:
```yaml
permissions:
  contents: write
  pull-requests: write
```

**Deployment Jobs**:
```yaml
permissions:
  contents: read
  id-token: write  # For Azure OIDC
```

### 4. Environment Protection Configuration

**Repository Settings → Environments**:

#### Development Environment
- Protection rules: None (auto-deploy)
- Secrets: `AZURE_CREDENTIALS`

#### Staging Environment
- Protection rules: Required reviewers (team leads)
- Wait timer: 5 minutes
- Secrets: `AZURE_CREDENTIALS`

#### Production Environment
- Protection rules: Required reviewers (administrators)
- Wait timer: 30 minutes
- Branch restrictions: main only
- Secrets: `AZURE_CREDENTIALS`

### 5. Required Repository Secrets

```
AZURE_CREDENTIALS - Service principal JSON for Azure authentication
SEMGREP_APP_TOKEN - Optional, for enhanced Semgrep scanning
PAT_TOKEN - Personal access token for documentation updates (if needed)
```

#### Azure Credentials Format
```json
{
  "clientId": "00000000-0000-0000-0000-000000000000",
  "clientSecret": "your-client-secret",
  "subscriptionId": "00000000-0000-0000-0000-000000000000",
  "tenantId": "00000000-0000-0000-0000-000000000000"
}
```

### 6. Branch Protection Rules

**Main Branch Protection**:
- Require pull request reviews
- Require status checks to pass:
  - Security Scan
  - Lint and Format
  - Validate Terraform
  - Run Tests
- Include administrators
- Restrict pushes

### 7. Workflow Optimization

#### For Pull Requests
- Use changed file detection to speed up validation
- Run only relevant tests for modified components
- Cache Terraform providers and modules

#### For Main Branch
- Progressive deployment with manual gates
- Artifact storage for plans and test results
- Notification integration for failures

### 8. Local Development Alignment

**Pre-commit Hook Configuration** (.pre-commit-config.yaml):
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: checkov
```

**Local Validation Script**:
```bash
./scripts/validate-terraform.sh
```

### 9. Monitoring and Troubleshooting

#### Workflow Logs
- Navigate to Actions tab in GitHub repository
- Select failed workflow run
- Download logs for detailed error analysis
- Check individual job logs for specific failures

#### Security Findings
- Navigate to Security tab in GitHub repository
- Review Code scanning alerts
- Address high and critical findings promptly
- Configure notification preferences

#### Failed Deployments
- Check Azure resource logs
- Verify service principal permissions
- Review Terraform plan outputs
- Validate environment variable configurations

### 10. Performance Optimization

#### Caching Strategy
```yaml
- name: Cache Terraform providers
  uses: actions/cache@v3
  with:
    path: |
      ~/.terraform.d/plugin-cache
    key: ${{ runner.os }}-terraform-${{ hashFiles('**/.terraform.lock.hcl') }}
    restore-keys: |
      ${{ runner.os }}-terraform-
```

#### Matrix Parallel Execution
```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
  max-parallel: 3
```

#### Artifact Management
```yaml
- name: Upload plan artifacts
  uses: actions/upload-artifact@v3
  with:
    name: terraform-plans
    path: environments/*/tfplan
    retention-days: 30
```

This configuration ensures reliable, secure, and efficient CI/CD operations for the Terraform lab infrastructure.