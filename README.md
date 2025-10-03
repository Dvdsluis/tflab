# Terraform Lab# Terraform Lab# Terraform Lab# terraform-docs



[![Terraform CI/CD](https://github.com/Dvdsluis/tflab/workflows/Terraform%20CI/CD%20Pipeline/badge.svg)](https://github.com/Dvdsluis/tflab/actions)



A comprehensive Terraform laboratory for learning Infrastructure as Code with Azure, featuring enterprise-grade CI/CD pipelines, security scanning, and automated documentation.[![Terraform CI/CD](https://github.com/Dvdsluis/tflab/workflows/Terraform%20CI/CD%20Pipeline/badge.svg)](https://github.com/Dvdsluis/tflab/actions)



## Features



- **Multi-environment setup**: Dev, Staging, and Production environmentsA comprehensive Terraform laboratory for learning Infrastructure as Code with Azure, featuring enterprise-grade CI/CD pipelines, security scanning, and automated documentation.[![Terraform CI/CD](https://github.com/Dvdsluis/tflab/workflows/Terraform%20CI/CD%20Pipeline/badge.svg)](https://github.com/Dvdsluis/tflab/actions)[![Build Status](https://github.com/terraform-docs/terraform-docs/workflows/ci/badge.svg)](https://github.com/terraform-docs/terraform-docs/actions) [![GoDoc](https://pkg.go.dev/badge/github.com/terraform-docs/terraform-docs)](https://pkg.go.dev/github.com/terraform-docs/terraform-docs) [![Go Report Card](https://goreportcard.com/badge/github.com/terraform-docs/terraform-docs)](https://goreportcard.com/report/github.com/terraform-docs/terraform-docs) [![Codecov Report](https://codecov.io/gh/terraform-docs/terraform-docs/branch/master/graph/badge.svg)](https://codecov.io/gh/terraform-docs/terraform-docs) [![License](https://img.shields.io/github/license/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/blob/master/LICENSE) [![Latest release](https://img.shields.io/github/v/release/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/releases)

- **Modular architecture**: Reusable networking, compute, and database modules  

- **Enterprise security**: Hardened modules with SSH-only access and security scanning

- **Automated testing**: Native Terraform tests and Terratest integration

- **CI/CD pipeline**: GitHub Actions with automated validation, security scans, and deployment## Features

- **Documentation**: Auto-generated module documentation with terraform-docs



## Quick Start

- **Multi-environment setup**: Dev, Staging, and Production environmentsA comprehensive Terraform laboratory for learning Infrastructure as Code with Azure, featuring enterprise-grade CI/CD pipelines, security scanning, and automated documentation.![terraform-docs-teaser](./images/terraform-docs-teaser.png)

1. **Clone the repository**:

   ```bash- **Modular architecture**: Reusable networking, compute, and database modules  

   git clone https://github.com/Dvdsluis/tflab.git

   cd tflab- **Enterprise security**: Hardened modules with SSH-only access and security scanning

   ```

- **Automated testing**: Native Terraform tests and Terratest integration

2. **Initialize Terraform** (choose an environment):

   ```bash- **CI/CD pipeline**: GitHub Actions with automated validation, security scans, and deployment## Features## What is terraform-docs

   cd environments/dev

   terraform init- **Documentation**: Auto-generated module documentation with terraform-docs

   terraform plan

   terraform apply

   ```

## Quick Start

3. **Validate configurations**:

   ```bash- **Multi-environment setup**: Dev, Staging, and Production environmentsA utility to generate documentation from Terraform modules in various output formats.

   # Run all validations

   ./scripts/validate-terraform.sh1. **Clone the repository**:

   

   # Or use VS Code task (Ctrl+Shift+P -> "Tasks: Run Task")   ```bash- **Modular architecture**: Reusable networking, compute, and database modules  

   ```

   git clone https://github.com/Dvdsluis/tflab.git

## Project Structure

   cd tflab- **Enterprise security**: Hardened modules with SSH-only access and security scanning## Installation

```

tflab/   ```

├── environments/          # Environment-specific configurations

│   ├── dev/              # Development environment- **Automated testing**: Native Terraform tests and Terratest integration

│   ├── staging/          # Staging environment

│   └── prod/             # Production environment2. **Initialize Terraform** (choose an environment):

├── modules/              # Reusable Terraform modules

│   ├── networking/       # VNet, subnets, NSGs, NAT Gateway   ```bash- **CI/CD pipeline**: GitHub Actions with automated validation, security scans, and deploymentmacOS users can install using [Homebrew]:

│   ├── compute/          # VM Scale Sets, Load Balancers

│   └── database/         # PostgreSQL, Key Vault   cd environments/dev

├── tests/                # Native Terraform tests

├── scripts/              # Automation scripts   terraform init- **Documentation**: Auto-generated module documentation with terraform-docs

├── .github/workflows/    # CI/CD pipeline definitions

└── docs/                 # Additional documentation   terraform plan

```

   terraform apply```bash

## Environments

   ```

### Development (dev)

- **Purpose**: Development and testing## Quick Startbrew install terraform-docs

- **VM Sizes**: Standard_B1s (web), Standard_B1ms (app)

- **Database**: Basic PostgreSQL Flexible Server3. **Validate configurations**:

- **Features**: NAT Gateway enabled, Bastion disabled

   ```bash```

### Staging (staging)  

- **Purpose**: Pre-production testing   # Run all validations

- **VM Sizes**: Standard_B2s (web), Standard_B2ms (app)

- **Database**: General Purpose PostgreSQL   ./scripts/validate-terraform.sh1. **Clone the repository**:

- **Features**: NAT Gateway enabled, Bastion enabled

   

### Production (prod)

- **Purpose**: Production workloads   # Or use VS Code task (Ctrl+Shift+P -> "Tasks: Run Task")   ```bashor

- **VM Sizes**: Standard_D2s_v3 (web), Standard_D4s_v3 (app)

- **Database**: Business Critical PostgreSQL   ```

- **Features**: Full redundancy, enhanced monitoring

   git clone https://github.com/Dvdsluis/tflab.git

## Modules

## Project Structure

### Networking Module

Creates a secure network foundation with:   cd tflab```bash

- Virtual Network with multiple subnets (public, private, database)

- Network Security Groups with least-privilege rules```

- NAT Gateway for private subnet internet access

- Route tables for traffic controltflab/   ```brew install terraform-docs/tap/terraform-docs



### Compute Module├── environments/          # Environment-specific configurations

Deploys scalable compute infrastructure:

- Virtual Machine Scale Sets for web and app tiers│   ├── dev/              # Development environment```

- Azure Load Balancers with health probes

- SSH-only authentication (no passwords)│   ├── staging/          # Staging environment

- Auto-scaling configuration

│   └── prod/             # Production environment2. **Initialize Terraform** (choose an environment):

### Database Module

Provides managed database services:├── modules/              # Reusable Terraform modules

- PostgreSQL Flexible Server with configurable performance tiers

- Azure Key Vault for credential management│   ├── networking/       # VNet, subnets, NSGs, NAT Gateway   ```bashWindows users can install using [Scoop]:

- Automated backups and point-in-time recovery

- Network isolation with delegated subnets│   ├── compute/          # VM Scale Sets, Load Balancers



## Security Features│   └── database/         # PostgreSQL, Key Vault   cd environments/dev



### Infrastructure Security├── tests/                # Native Terraform tests

- **SSH-only authentication**: No admin passwords configured

- **Network isolation**: Proper subnet segmentation with NSGs├── scripts/              # Automation scripts   terraform init```bash

- **Encryption**: Disk encryption enabled for all VMs

- **Key management**: Azure Key Vault for sensitive data├── .github/workflows/    # CI/CD pipeline definitions



### CI/CD Security└── docs/                 # Additional documentation   terraform planscoop bucket add terraform-docs https://github.com/terraform-docs/scoop-bucket

- **Vulnerability scanning**: Trivy for container and infrastructure scanning

- **Policy compliance**: Checkov for security best practices```

- **Static analysis**: Semgrep for code quality and security issues

- **Secrets management**: GitHub secrets for sensitive variables   terraform applyscoop install terraform-docs



## Testing## Environments



### Native Terraform Tests   ``````

Located in the `tests/` directory, these use Terraform's built-in testing framework:

### Development (dev)

```bash

# Run all tests- **Purpose**: Development and testing

terraform test

- **VM Sizes**: Standard_B1s (web), Standard_B1ms (app)

# Run specific test

terraform test tests/networking.tftest.hcl- **Database**: Basic PostgreSQL Flexible Server3. **Validate configurations**:or [Chocolatey]:

```

- **Features**: NAT Gateway enabled, Bastion disabled

### Validation Scripts

Comprehensive validation using the included scripts:   ```bash



```bash### Staging (staging)  

# Full validation suite

./scripts/validate-terraform.sh- **Purpose**: Pre-production testing   # Run all validations```bash



# Individual validation components- **VM Sizes**: Standard_B2s (web), Standard_B2ms (app)

terraform fmt -check -recursive

terraform validate- **Database**: General Purpose PostgreSQL   ./scripts/validate-terraform.shchoco install terraform-docs

terraform plan -detailed-exitcode

```- **Features**: NAT Gateway enabled, Bastion enabled



## CI/CD Pipeline   ```



The GitHub Actions pipeline provides:### Production (prod)



1. **Pull Request Validation**- **Purpose**: Production workloads   # Or use VS Code task (Ctrl+Shift+P -> "Tasks: Run Task")

   - Terraform formatting check

   - Configuration validation- **VM Sizes**: Standard_D2s_v3 (web), Standard_D4s_v3 (app)

   - Security scanning

   - Test execution- **Database**: Business Critical PostgreSQL   ```Stable binaries are also available on the [releases] page. To install, download the



2. **Security Scanning**- **Features**: Full redundancy, enhanced monitoring

   - Trivy vulnerability scanning

   - Checkov policy compliancebinary for your platform from "Assets" and place this into your `$PATH`:

   - Semgrep static analysis

## Modules

3. **Deployment Pipeline**

   - Automated planning for all environments## Project Structure

   - Manual approval for production deployments

   - Terraform state management### Networking Module

   - Documentation updates

Creates a secure network foundation with:```bash

## Prerequisites

- Virtual Network with multiple subnets (public, private, database)

### Local Development

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0- Network Security Groups with least-privilege rules```curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.18.0/terraform-docs-v0.18.0-$(uname)-amd64.tar.gz

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [terraform-docs](https://terraform-docs.io/user-guide/installation/) (optional)- NAT Gateway for private subnet internet access

- [TFLint](https://github.com/terraform-linters/tflint) (optional)

- Route tables for traffic controltflab/tar -xzf terraform-docs.tar.gz

### Azure Requirements

- Azure subscription with appropriate permissions

- Resource group for deployment target

- Service principal for CI/CD (if using automated deployment)### Compute Module├── environments/          # Environment-specific configurationschmod +x terraform-docs



## ConfigurationDeploys scalable compute infrastructure:



### Environment Variables- Virtual Machine Scale Sets for web and app tiers│   ├── dev/              # Development environmentmv terraform-docs /usr/local/bin/terraform-docs

Set these for local development:

- Azure Load Balancers with health probes

```bash

export ARM_SUBSCRIPTION_ID="your-subscription-id"- SSH-only authentication (no passwords)│   ├── staging/          # Staging environment```

export ARM_TENANT_ID="your-tenant-id"

export ARM_CLIENT_ID="your-client-id"- Auto-scaling configuration

export ARM_CLIENT_SECRET="your-client-secret"

```│   └── prod/             # Production environment



### Terraform Variables### Database Module

Each environment has its own `terraform.tfvars` file with environment-specific values:

Provides managed database services:├── modules/              # Reusable Terraform modules**NOTE:** Windows releases are in `ZIP` format.

- **Network configuration**: CIDR blocks, subnet definitions

- **Compute configuration**: VM sizes, instance counts- PostgreSQL Flexible Server with configurable performance tiers

- **Database configuration**: Performance tiers, backup settings

- **Security configuration**: SSH keys, access rules- Azure Key Vault for credential management│   ├── networking/       # VNet, subnets, NSGs, NAT Gateway



## Learning Path- Automated backups and point-in-time recovery



This lab is designed as a progressive learning experience:- Network isolation with delegated subnets│   ├── compute/          # VM Scale Sets, Load BalancersThe latest version can be installed using `go install` or `go get`:



1. **Start with Development**: Deploy the dev environment to understand basic concepts

2. **Explore Modules**: Examine the modular architecture and reusable components

3. **Security Hardening**: Review security features and best practices## Security Features│   └── database/         # PostgreSQL, Key Vault

4. **CI/CD Integration**: Set up automated pipelines for consistent deployments

5. **Testing Strategy**: Implement comprehensive testing with native Terraform tests

6. **Production Readiness**: Graduate to staging and production environments

### Infrastructure Security├── tests/                # Native Terraform tests```bash

## Troubleshooting

- **SSH-only authentication**: No admin passwords configured

### Common Issues

- **Network isolation**: Proper subnet segmentation with NSGs├── scripts/              # Automation scripts# go1.17+

**Authentication Errors**

```bash- **Encryption**: Disk encryption enabled for all VMs

# Login to Azure CLI

az login- **Key management**: Azure Key Vault for sensitive data├── .github/workflows/    # CI/CD pipeline definitionsgo install github.com/terraform-docs/terraform-docs@v0.18.0



# Set subscription

az account set --subscription "your-subscription-id"

### CI/CD Security└── docs/                 # Additional documentation```

# Verify authentication

az account show- **Vulnerability scanning**: Trivy for container and infrastructure scanning

```

- **Policy compliance**: Checkov for security best practices```

**State Lock Issues**

```bash- **Static analysis**: Semgrep for code quality and security issues

# Force unlock (use with caution)

terraform force-unlock LOCK_ID- **Secrets management**: GitHub secrets for sensitive variables```bash

```



**Module Source Errors**

```bash## Testing## Environments# go1.16

# Reinitialize modules

terraform init -upgrade

```

### Native Terraform TestsGO111MODULE="on" go get github.com/terraform-docs/terraform-docs@v0.18.0

### Getting Help

Located in the `tests/` directory, these use Terraform's built-in testing framework:

- Check the [LEARNING_GUIDE.md](LEARNING_GUIDE.md) for detailed tutorials

- Review module documentation in respective `README.md` files### Development (dev)```

- Examine test files for usage examples

- Check GitHub Issues for known problems and solutions```bash



## Contributing# Run all tests- **Purpose**: Development and testing



Contributions are welcome! Please:terraform test



1. Fork the repository- **VM Sizes**: Standard_B1s (web), Standard_B1ms (app)**NOTE:** please use the latest Go to do this, minimum `go1.16` is required.

2. Create a feature branch

3. Make your changes with appropriate tests# Run specific test

4. Ensure all validations pass

5. Submit a pull requestterraform test tests/networking.tftest.hcl- **Database**: Basic PostgreSQL Flexible Server



## License```



This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.- **Features**: NAT Gateway enabled, Bastion disabledThis will put `terraform-docs` in `$(go env GOPATH)/bin`. If you encounter the error



## Acknowledgments### Validation Scripts



- Built with [Terraform](https://www.terraform.io/)Comprehensive validation using the included scripts:`terraform-docs: command not found` after installation then you may need to either add

- Uses [Azure Resource Manager](https://azure.microsoft.com/en-us/features/resource-manager/)

- Documentation generated with [terraform-docs](https://terraform-docs.io/)

- Security scanning by [Trivy](https://trivy.dev/), [Checkov](https://www.checkov.io/), and [Semgrep](https://semgrep.dev/)
```bash### Staging (staging)  that directory to your `$PATH` as shown [here] or do a manual installation by cloning

# Full validation suite

./scripts/validate-terraform.sh- **Purpose**: Pre-production testingthe repo and run `make build` from the repository which will put `terraform-docs` in:



# Individual validation components- **VM Sizes**: Standard_B2s (web), Standard_B2ms (app)

terraform fmt -check -recursive

terraform validate- **Database**: General Purpose PostgreSQL```bash

terraform plan -detailed-exitcode

```- **Features**: NAT Gateway enabled, Bastion enabled$(go env GOPATH)/src/github.com/terraform-docs/terraform-docs/bin/$(uname | tr '[:upper:]' '[:lower:]')-amd64/terraform-docs



## CI/CD Pipeline```



The GitHub Actions pipeline provides:### Production (prod)



1. **Pull Request Validation**- **Purpose**: Production workloads## Usage

   - Terraform formatting check

   - Configuration validation- **VM Sizes**: Standard_D2s_v3 (web), Standard_D4s_v3 (app)

   - Security scanning

   - Test execution- **Database**: Business Critical PostgreSQL### Running the binary directly



2. **Security Scanning**- **Features**: Full redundancy, enhanced monitoring

   - Trivy vulnerability scanning

   - Checkov policy complianceTo run and generate documentation into README within a directory:

   - Semgrep static analysis

## Modules

3. **Deployment Pipeline**

   - Automated planning for all environments```bash

   - Manual approval for production deployments

   - Terraform state management### Networking Moduleterraform-docs markdown table --output-file README.md --output-mode inject /path/to/module

   - Documentation updates

Creates a secure network foundation with:```

## Prerequisites

- Virtual Network with multiple subnets (public, private, database)

### Local Development

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0- Network Security Groups with least-privilege rulesCheck [`output`] configuration for more details and examples.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [terraform-docs](https://terraform-docs.io/user-guide/installation/) (optional)- NAT Gateway for private subnet internet access

- [TFLint](https://github.com/terraform-linters/tflint) (optional)

- Route tables for traffic control### Using docker

### Azure Requirements

- Azure subscription with appropriate permissions

- Resource group for deployment target

- Service principal for CI/CD (if using automated deployment)### Compute Moduleterraform-docs can be run as a container by mounting a directory with `.tf`



## ConfigurationDeploys scalable compute infrastructure:files in it and run the following command:



### Environment Variables- Virtual Machine Scale Sets for web and app tiers

Set these for local development:

- Azure Load Balancers with health probes```bash

```bash

export ARM_SUBSCRIPTION_ID="your-subscription-id"- SSH-only authentication (no passwords)docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.18.0 markdown /terraform-docs

export ARM_TENANT_ID="your-tenant-id"

export ARM_CLIENT_ID="your-client-id"- Auto-scaling configuration```

export ARM_CLIENT_SECRET="your-client-secret"

```



### Terraform Variables### Database ModuleIf `output.file` is not enabled for this module, generated output can be redirected

Each environment has its own `terraform.tfvars` file with environment-specific values:

Provides managed database services:back to a file:

- **Network configuration**: CIDR blocks, subnet definitions

- **Compute configuration**: VM sizes, instance counts- PostgreSQL Flexible Server with configurable performance tiers

- **Database configuration**: Performance tiers, backup settings

- **Security configuration**: SSH keys, access rules- Azure Key Vault for credential management```bash



## Learning Path- Automated backups and point-in-time recoverydocker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.18.0 markdown /terraform-docs > doc.md



This lab is designed as a progressive learning experience:- Network isolation with delegated subnets```



1. **Start with Development**: Deploy the dev environment to understand basic concepts

2. **Explore Modules**: Examine the modular architecture and reusable components

3. **Security Hardening**: Review security features and best practices## Security Features**NOTE:** Docker tag `latest` refers to _latest_ stable released version and `edge`

4. **CI/CD Integration**: Set up automated pipelines for consistent deployments

5. **Testing Strategy**: Implement comprehensive testing with native Terraform testsrefers to HEAD of `master` at any given point in time.

6. **Production Readiness**: Graduate to staging and production environments

### Infrastructure Security

## Troubleshooting

- **SSH-only authentication**: No admin passwords configured### Using GitHub Actions

### Common Issues

- **Network isolation**: Proper subnet segmentation with NSGs

**Authentication Errors**

```bash- **Encryption**: Disk encryption enabled for all VMsTo use terraform-docs GitHub Action, configure a YAML workflow file (e.g.

# Login to Azure CLI

az login- **Key management**: Azure Key Vault for sensitive data`.github/workflows/documentation.yml`) with the following:



# Set subscription

az account set --subscription "your-subscription-id"

### CI/CD Security```yaml

# Verify authentication

az account show- **Vulnerability scanning**: Trivy for container and infrastructure scanningname: Generate terraform docs

```

- **Policy compliance**: Checkov for security best practiceson:

**State Lock Issues**

```bash- **Static analysis**: Semgrep for code quality and security issues  - pull_request

# Force unlock (use with caution)

terraform force-unlock LOCK_ID- **Secrets management**: GitHub secrets for sensitive variables

```

jobs:

**Module Source Errors**

```bash## Testing  docs:

# Reinitialize modules

terraform init -upgrade    runs-on: ubuntu-latest

```

### Native Terraform Tests    steps:

### Getting Help

Located in the `tests/` directory, these use Terraform's built-in testing framework:    - uses: actions/checkout@v3

- Check the [LEARNING_GUIDE.md](LEARNING_GUIDE.md) for detailed tutorials

- Review module documentation in respective `README.md` files      with:

- Examine test files for usage examples

- Check GitHub Issues for known problems and solutions```bash        ref: ${{ github.event.pull_request.head.ref }}



## Contributing# Run all tests



Contributions are welcome! Please:terraform test    - name: Render terraform docs and push changes back to PR



1. Fork the repository      uses: terraform-docs/gh-actions@main

2. Create a feature branch

3. Make your changes with appropriate tests# Run specific test      with:

4. Ensure all validations pass

5. Submit a pull requestterraform test tests/networking.tftest.hcl        working-dir: .



## License```        output-file: README.md



This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.        output-method: inject



## Acknowledgments### Validation Scripts        git-push: "true"



- Built with [Terraform](https://www.terraform.io/)Comprehensive validation using the included scripts:```

- Uses [Azure Resource Manager](https://azure.microsoft.com/en-us/features/resource-manager/)

- Documentation generated with [terraform-docs](https://terraform-docs.io/)

- Security scanning by [Trivy](https://trivy.dev/), [Checkov](https://www.checkov.io/), and [Semgrep](https://semgrep.dev/)
```bashRead more about [terraform-docs GitHub Action] and its configuration and

# Full validation suiteexamples.

./scripts/validate-terraform.sh

### pre-commit hook

# Individual validation components

terraform fmt -check -recursiveWith pre-commit, you can ensure your Terraform module documentation is kept

terraform validateup-to-date each time you make a commit.

terraform plan -detailed-exitcode

```First [install pre-commit] and then create or update a `.pre-commit-config.yaml`

in the root of your Git repo with at least the following content:

## CI/CD Pipeline

```yaml

The GitHub Actions pipeline provides:repos:

  - repo: https://github.com/terraform-docs/terraform-docs

1. **Pull Request Validation**    rev: "v0.18.0"

   - Terraform formatting check    hooks:

   - Configuration validation      - id: terraform-docs-go

   - Security scanning        args: ["markdown", "table", "--output-file", "README.md", "./mymodule/path"]

   - Test execution```



2. **Security Scanning**Then run:

   - Trivy vulnerability scanning

   - Checkov policy compliance```bash

   - Semgrep static analysispre-commit install

pre-commit install-hooks

3. **Deployment Pipeline**```

   - Automated planning for all environments

   - Manual approval for production deploymentsFurther changes to your module's `.tf` files will cause an update to documentation

   - Terraform state managementwhen you make a commit.

   - Documentation updates

## Configuration

## Prerequisites

terraform-docs can be configured with a yaml file. The default name of this file is

### Local Development`.terraform-docs.yml` and the path order for locating it is:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)1. root of module directory

- [terraform-docs](https://terraform-docs.io/user-guide/installation/) (optional)1. `.config/` folder at root of module directory

- [TFLint](https://github.com/terraform-linters/tflint) (optional)1. current directory

1. `.config/` folder at current directory

### Azure Requirements1. `$HOME/.tfdocs.d/`

- Azure subscription with appropriate permissions

- Resource group for deployment target```yaml

- Service principal for CI/CD (if using automated deployment)formatter: "" # this is required



## Configurationversion: ""



### Environment Variablesheader-from: main.tf

Set these for local development:footer-from: ""



```bashrecursive:

export ARM_SUBSCRIPTION_ID="your-subscription-id"  enabled: false

export ARM_TENANT_ID="your-tenant-id"  path: modules

export ARM_CLIENT_ID="your-client-id"  include-main: true

export ARM_CLIENT_SECRET="your-client-secret"

```sections:

  hide: []

### Terraform Variables  show: []

Each environment has its own `terraform.tfvars` file with environment-specific values:

content: ""

- **Network configuration**: CIDR blocks, subnet definitions

- **Compute configuration**: VM sizes, instance countsoutput:

- **Database configuration**: Performance tiers, backup settings  file: ""

- **Security configuration**: SSH keys, access rules  mode: inject

  template: |-

## Learning Path    <!-- BEGIN_TF_DOCS -->

    {{ .Content }}

This lab is designed as a progressive learning experience:    <!-- END_TF_DOCS -->



1. **Start with Development**: Deploy the dev environment to understand basic conceptsoutput-values:

2. **Explore Modules**: Examine the modular architecture and reusable components  enabled: false

3. **Security Hardening**: Review security features and best practices  from: ""

4. **CI/CD Integration**: Set up automated pipelines for consistent deployments

5. **Testing Strategy**: Implement comprehensive testing with native Terraform testssort:

6. **Production Readiness**: Graduate to staging and production environments  enabled: true

  by: name

## Troubleshooting

settings:

### Common Issues  anchor: true

  color: true

**Authentication Errors**  default: true

```bash  description: false

# Login to Azure CLI  escape: true

az login  hide-empty: false

  html: true

# Set subscription  indent: 2

az account set --subscription "your-subscription-id"  lockfile: true

  read-comments: true

# Verify authentication  required: true

az account show  sensitive: true

```  type: true

```

**State Lock Issues**

```bash## Content Template

# Force unlock (use with caution)

terraform force-unlock LOCK_IDGenerated content can be customized further away with `content` in configuration.

```If the `content` is empty the default order of sections is used.



**Module Source Errors**Compatible formatters for customized content are `asciidoc` and `markdown`. `content`

```bashwill be ignored for other formatters.

# Reinitialize modules

terraform init -upgrade`content` is a Go template with following additional variables:

```

- `{{ .Header }}`

### Getting Help- `{{ .Footer }}`

- `{{ .Inputs }}`

- Check the [LEARNING_GUIDE.md](LEARNING_GUIDE.md) for detailed tutorials- `{{ .Modules }}`

- Review module documentation in respective `README.md` files- `{{ .Outputs }}`

- Examine test files for usage examples- `{{ .Providers }}`

- Check GitHub Issues for known problems and solutions- `{{ .Requirements }}`

- `{{ .Resources }}`

## Contributing

and following functions:

Contributions are welcome! Please:

- `{{ include "relative/path/to/file" }}`

1. Fork the repository

2. Create a feature branchThese variables are the generated output of individual sections in the selected

3. Make your changes with appropriate testsformatter. For example `{{ .Inputs }}` is Markdown Table representation of _inputs_

4. Ensure all validations passwhen formatter is set to `markdown table`.

5. Submit a pull request

Note that sections visibility (i.e. `sections.show` and `sections.hide`) takes

## Licenseprecedence over the `content`.



This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.Additionally there's also one extra special variable avaialble to the `content`:



## Acknowledgments- `{{ .Module }}`



- Built with [Terraform](https://www.terraform.io/)As opposed to the other variables mentioned above, which are generated sections

- Uses [Azure Resource Manager](https://azure.microsoft.com/en-us/features/resource-manager/)based on a selected formatter, the `{{ .Module }}` variable is just a `struct`

- Documentation generated with [terraform-docs](https://terraform-docs.io/)representing a [Terraform module].

- Security scanning by [Trivy](https://trivy.dev/), [Checkov](https://www.checkov.io/), and [Semgrep](https://semgrep.dev/)
````yaml
content: |-
  Any arbitrary text can be placed anywhere in the content

  {{ .Header }}

  and even in between sections

  {{ .Providers }}

  and they don't even need to be in the default order

  {{ .Outputs }}

  include any relative files

  {{ include "relative/path/to/file" }}

  {{ .Inputs }}

  # Examples

  ```hcl
  {{ include "examples/foo/main.tf" }}
  ```

  ## Resources

  {{ range .Module.Resources }}
  - {{ .GetMode }}.{{ .Spec }} ({{ .Position.Filename }}#{{ .Position.Line }})
  {{- end }}
````

## Build on top of terraform-docs

terraform-docs primary use-case is to be utilized as a standalone binary, but
some parts of it is also available publicly and can be imported in your project
as a library.

```go
import (
    "github.com/terraform-docs/terraform-docs/format"
    "github.com/terraform-docs/terraform-docs/print"
    "github.com/terraform-docs/terraform-docs/terraform"
)

// buildTerraformDocs for module root `path` and provided content `tmpl`.
func buildTerraformDocs(path string, tmpl string) (string, error) {
    config := print.DefaultConfig()
    config.ModuleRoot = path // module root path (can be relative or absolute)

    module, err := terraform.LoadWithOptions(config)
    if err != nil {
        return "", err
    }

    // Generate in Markdown Table format
    formatter := format.NewMarkdownTable(config)

    if err := formatter.Generate(module); err != nil {
        return "", err
    }

    // // Note: if you don't intend to provide additional template for the generated
    // // content, or the target format doesn't provide templating (e.g. json, yaml,
    // // xml, or toml) you can use `Content()` function instead of `Render()`.
    // // `Content()` returns all the sections combined with predefined order.
    // return formatter.Content(), nil

    return formatter.Render(tmpl)
}
```

## Plugin

Generated output can be heavily customized with [`content`], but if using that
is not enough for your use-case, you can write your own plugin.

In order to install a plugin the following steps are needed:

- download the plugin and place it in `~/.tfdocs.d/plugins` (or `./.tfdocs.d/plugins`)
- make sure the plugin file name is `tfdocs-format-<NAME>`
- modify [`formatter`] of `.terraform-docs.yml` file to be `<NAME>`

**Important notes:**

- if the plugin file name is different than the example above, terraform-docs won't
be able to to pick it up nor register it properly
- you can only use plugin thorough `.terraform-docs.yml` file and it cannot be used
with CLI arguments

To create a new plugin create a new repository called `tfdocs-format-<NAME>` with
following `main.go`:

```go
package main

import (
    _ "embed" //nolint

    "github.com/terraform-docs/terraform-docs/plugin"
    "github.com/terraform-docs/terraform-docs/print"
    "github.com/terraform-docs/terraform-docs/template"
    "github.com/terraform-docs/terraform-docs/terraform"
)

func main() {
    plugin.Serve(&plugin.ServeOpts{
        Name:    "<NAME>",
        Version: "0.1.0",
        Printer: printerFunc,
    })
}

//go:embed sections.tmpl
var tplCustom []byte

// printerFunc the function being executed by the plugin client.
func printerFunc(config *print.Config, module *terraform.Module) (string, error) {
    tpl := template.New(config,
        &template.Item{Name: "custom", Text: string(tplCustom)},
    )

    rendered, err := tpl.Render("custom", module)
    if err != nil {
        return "", err
    }

    return rendered, nil
}
```

Please refer to [tfdocs-format-template] for more details. You can create a new
repository from it by clicking on `Use this template` button.

## Documentation

- **Users**
  - Read the [User Guide] to learn how to use terraform-docs
  - Read the [Formats Guide] to learn about different output formats of terraform-docs
  - Refer to [Config File Reference] for all the available configuration options
- **Developers**
  - Read [Contributing Guide] before submitting a pull request

Visit [our website] for all documentation.

## Community

- Discuss terraform-docs on [Slack]

## License

MIT License - Copyright (c) 2021 The terraform-docs Authors.

[Chocolatey]: https://www.chocolatey.org
[Config File Reference]: https://terraform-docs.io/user-guide/configuration/
[`content`]: https://terraform-docs.io/user-guide/configuration/content/
[Contributing Guide]: CONTRIBUTING.md
[Formats Guide]: https://terraform-docs.io/reference/terraform-docs/
[`formatter`]: https://terraform-docs.io/user-guide/configuration/formatter/
[here]: https://golang.org/doc/code.html#GOPATH
[Homebrew]: https://brew.sh
[install pre-commit]: https://pre-commit.com/#install
[`output`]: https://terraform-docs.io/user-guide/configuration/output/
[releases]: https://github.com/terraform-docs/terraform-docs/releases
[Scoop]: https://scoop.sh/
[Slack]: https://slack.terraform-docs.io/
[terraform-docs GitHub Action]: https://github.com/terraform-docs/gh-actions
[Terraform module]: https://pkg.go.dev/github.com/terraform-docs/terraform-docs/terraform#Module
[tfdocs-format-template]: https://github.com/terraform-docs/tfdocs-format-template
[our website]: https://terraform-docs.io/
[User Guide]: https://terraform-docs.io/user-guide/introduction/
