# Terraform Lab# terraform-docs



[![Terraform CI/CD](https://github.com/Dvdsluis/tflab/workflows/Terraform%20CI/CD%20Pipeline/badge.svg)](https://github.com/Dvdsluis/tflab/actions)[![Build Status](https://github.com/terraform-docs/terraform-docs/workflows/ci/badge.svg)](https://github.com/terraform-docs/terraform-docs/actions) [![GoDoc](https://pkg.go.dev/badge/github.com/terraform-docs/terraform-docs)](https://pkg.go.dev/github.com/terraform-docs/terraform-docs) [![Go Report Card](https://goreportcard.com/badge/github.com/terraform-docs/terraform-docs)](https://goreportcard.com/report/github.com/terraform-docs/terraform-docs) [![Codecov Report](https://codecov.io/gh/terraform-docs/terraform-docs/branch/master/graph/badge.svg)](https://codecov.io/gh/terraform-docs/terraform-docs) [![License](https://img.shields.io/github/license/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/blob/master/LICENSE) [![Latest release](https://img.shields.io/github/v/release/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/releases)



A comprehensive Terraform laboratory for learning Infrastructure as Code with Azure, featuring enterprise-grade CI/CD pipelines, security scanning, and automated documentation.![terraform-docs-teaser](./images/terraform-docs-teaser.png)



## Features## What is terraform-docs



- **Multi-environment setup**: Dev, Staging, and Production environmentsA utility to generate documentation from Terraform modules in various output formats.

- **Modular architecture**: Reusable networking, compute, and database modules  

- **Enterprise security**: Hardened modules with SSH-only access and security scanning## Installation

- **Automated testing**: Native Terraform tests and Terratest integration

- **CI/CD pipeline**: GitHub Actions with automated validation, security scans, and deploymentmacOS users can install using [Homebrew]:

- **Documentation**: Auto-generated module documentation with terraform-docs

```bash

## Quick Startbrew install terraform-docs

```

1. **Clone the repository**:

   ```bashor

   git clone https://github.com/Dvdsluis/tflab.git

   cd tflab```bash

   ```brew install terraform-docs/tap/terraform-docs

```

2. **Initialize Terraform** (choose an environment):

   ```bashWindows users can install using [Scoop]:

   cd environments/dev

   terraform init```bash

   terraform planscoop bucket add terraform-docs https://github.com/terraform-docs/scoop-bucket

   terraform applyscoop install terraform-docs

   ``````



3. **Run tests**:or [Chocolatey]:

   ```bash

   cd tests```bash

   terraform testchoco install terraform-docs

   ``````



## Project StructureStable binaries are also available on the [releases] page. To install, download the

binary for your platform from "Assets" and place this into your `$PATH`:

```

├── environments/          # Environment-specific configurations```bash

│   ├── dev/               # Development environmentcurl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.18.0/terraform-docs-v0.18.0-$(uname)-amd64.tar.gz

│   ├── staging/           # Staging environmenttar -xzf terraform-docs.tar.gz

│   └── prod/              # Production environmentchmod +x terraform-docs

├── modules/               # Reusable Terraform modulesmv terraform-docs /usr/local/bin/terraform-docs

│   ├── networking/        # VNet, subnets, NSGs```

│   ├── compute/           # VM Scale Sets, Load Balancers

│   └── database/          # PostgreSQL/MySQL with Key Vault**NOTE:** Windows releases are in `ZIP` format.

├── tests/                 # Terraform native tests

├── .github/workflows/     # CI/CD pipelinesThe latest version can be installed using `go install` or `go get`:

└── scripts/               # Utility scripts

``````bash

# go1.17+

## Modulesgo install github.com/terraform-docs/terraform-docs@v0.18.0

```

### Networking Module

- Virtual Network (VNet) with configurable CIDR```bash

- Public, private, and database subnets# go1.16

- Network Security Groups (NSGs) with security rulesGO111MODULE="on" go get github.com/terraform-docs/terraform-docs@v0.18.0

- Public IP addresses```



### Compute Module**NOTE:** please use the latest Go to do this, minimum `go1.16` is required.

- VM Scale Sets for web and application tiers

- Load balancers with health probesThis will put `terraform-docs` in `$(go env GOPATH)/bin`. If you encounter the error

- SSH key-based authentication (no password auth)`terraform-docs: command not found` after installation then you may need to either add

- Auto-scaling capabilitiesthat directory to your `$PATH` as shown [here] or do a manual installation by cloning

the repo and run `make build` from the repository which will put `terraform-docs` in:

### Database Module

- PostgreSQL or MySQL Flexible Server```bash

- Azure Key Vault for secrets management$(go env GOPATH)/src/github.com/terraform-docs/terraform-docs/bin/$(uname | tr '[:upper:]' '[:lower:]')-amd64/terraform-docs

- Network integration with database subnets```

- Backup and high availability options

## Usage

## Environment Configuration

### Running the binary directly

Each environment (dev/staging/prod) includes:

- Environment-specific variable valuesTo run and generate documentation into README within a directory:

- Terraform state configuration

- Resource naming conventions```bash

- Scaling configurationsterraform-docs markdown table --output-file README.md --output-mode inject /path/to/module

```

## Security Features

Check [`output`] configuration for more details and examples.

- **SSH-only access**: Password authentication disabled

- **Security scanning**: Trivy, Checkov, and Semgrep integration### Using docker

- **Secrets management**: Azure Key Vault for database credentials

- **Network security**: NSGs with least-privilege rulesterraform-docs can be run as a container by mounting a directory with `.tf`

- **Resource hardening**: Enterprise security best practicesfiles in it and run the following command:



## CI/CD Pipeline```bash

docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.18.0 markdown /terraform-docs

The GitHub Actions pipeline includes:```



1. **Security Scan**: Vulnerability and compliance scanningIf `output.file` is not enabled for this module, generated output can be redirected

2. **Lint and Format**: Code quality checksback to a file:

3. **Validate**: Terraform validation across environments

4. **Test**: Automated testing with Terraform native tests```bash

5. **Plan**: Generate deployment plans for reviewdocker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.18.0 markdown /terraform-docs > doc.md

6. **Deploy**: Automated deployment with approval gates```

7. **Documentation**: Auto-update module documentation

**NOTE:** Docker tag `latest` refers to _latest_ stable released version and `edge`

## Testingrefers to HEAD of `master` at any given point in time.



The project includes comprehensive testing:### Using GitHub Actions



- **Unit tests**: Individual module testingTo use terraform-docs GitHub Action, configure a YAML workflow file (e.g.

- **Integration tests**: Full environment testing`.github/workflows/documentation.yml`) with the following:

- **Security tests**: Configuration compliance

- **Documentation tests**: README and module docs validation```yaml

name: Generate terraform docs

Run tests locally:on:

```bash  - pull_request

cd tests

terraform initjobs:

terraform test  docs:

```    runs-on: ubuntu-latest

    steps:

## Contributing    - uses: actions/checkout@v3

      with:

1. Fork the repository        ref: ${{ github.event.pull_request.head.ref }}

2. Create a feature branch

3. Make your changes    - name: Render terraform docs and push changes back to PR

4. Run tests and formatting      uses: terraform-docs/gh-actions@main

5. Submit a pull request      with:

        working-dir: .

## License        output-file: README.md

        output-method: inject

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.        git-push: "true"

```

## Support

Read more about [terraform-docs GitHub Action] and its configuration and

For questions and support:examples.

- Create an issue in this repository

- Review the examples in the `examples/` directory### pre-commit hook

- Check the module documentation in each module's README

With pre-commit, you can ensure your Terraform module documentation is kept

---up-to-date each time you make a commit.



**Note**: This is a learning laboratory. Ensure you understand the costs associated with Azure resources before deploying to production environments.First [install pre-commit] and then create or update a `.pre-commit-config.yaml`
in the root of your Git repo with at least the following content:

```yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.18.0"
    hooks:
      - id: terraform-docs-go
        args: ["markdown", "table", "--output-file", "README.md", "./mymodule/path"]
```

Then run:

```bash
pre-commit install
pre-commit install-hooks
```

Further changes to your module's `.tf` files will cause an update to documentation
when you make a commit.

## Configuration

terraform-docs can be configured with a yaml file. The default name of this file is
`.terraform-docs.yml` and the path order for locating it is:

1. root of module directory
1. `.config/` folder at root of module directory
1. current directory
1. `.config/` folder at current directory
1. `$HOME/.tfdocs.d/`

```yaml
formatter: "" # this is required

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules
  include-main: true

sections:
  hide: []
  show: []

content: ""

output:
  file: ""
  mode: inject
  template: |-
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

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

## Content Template

Generated content can be customized further away with `content` in configuration.
If the `content` is empty the default order of sections is used.

Compatible formatters for customized content are `asciidoc` and `markdown`. `content`
will be ignored for other formatters.

`content` is a Go template with following additional variables:

- `{{ .Header }}`
- `{{ .Footer }}`
- `{{ .Inputs }}`
- `{{ .Modules }}`
- `{{ .Outputs }}`
- `{{ .Providers }}`
- `{{ .Requirements }}`
- `{{ .Resources }}`

and following functions:

- `{{ include "relative/path/to/file" }}`

These variables are the generated output of individual sections in the selected
formatter. For example `{{ .Inputs }}` is Markdown Table representation of _inputs_
when formatter is set to `markdown table`.

Note that sections visibility (i.e. `sections.show` and `sections.hide`) takes
precedence over the `content`.

Additionally there's also one extra special variable avaialble to the `content`:

- `{{ .Module }}`

As opposed to the other variables mentioned above, which are generated sections
based on a selected formatter, the `{{ .Module }}` variable is just a `struct`
representing a [Terraform module].

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
