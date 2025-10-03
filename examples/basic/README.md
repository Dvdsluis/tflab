# Terraform Lab - Basic Example

This example demonstrates how to use the Terraform lab modules to create a simple web application infrastructure.

## Overview

This example creates:
- A VPC with public and private subnets
- A simple web server in the public subnet
- Basic security groups
- No database (for simplicity)

## Usage

```bash
# Initialize and apply
terraform init
terraform apply

# Get the web server URL
terraform output web_url

# Clean up
terraform destroy
```

## Architecture

```
Internet
    |
    v
[Load Balancer] (Public Subnet)
    |
    v
[Web Servers] (Public Subnet)
```

## Learning Objectives

1. Understand basic module usage
2. See how outputs are used
3. Practice with simplified configuration
4. Learn about variable overrides