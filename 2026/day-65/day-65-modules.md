# Day 65 - Terraform Modules: Build Reusable Infrastructure

## Overview
Terraform modules allow you to package, reuse, and share infrastructure code across multiple projects. Think of modules as reusable functions in programming -- write once, call many times.

---

## Task 1: Understand Module Structure

### Module Architecture Explained

**Root Module vs Child Modules:**

```
Root Module: The top-level configuration in your Terraform directory
            └─ This is what you run `terraform apply` from
            └─ Calls child modules to compose infrastructure

Child Module: Reusable, encapsulated infrastructure components
             └─ Located in subdirectories (typically ./modules/)
             └─ Has inputs (variables) and outputs
             └─ Can be called multiple times with different values
             └─ Can be version-controlled separately
```

### Standard Module Directory Structure

```
terraform-modules/
├── main.tf                     # Root module - calls child modules
├── variables.tf                # Root module inputs
├── outputs.tf                  # Root module outputs
├── providers.tf                # Provider configuration
├── terraform.tfvars            # Variable values (not committed)
├── .gitignore
├── README.md
└── modules/
    ├── ec2-instance/
    │   ├── main.tf            # EC2 resource definition
    │   ├── variables.tf       # Module inputs
    │   ├── outputs.tf         # Module outputs
    │   └── README.md          # Module documentation
    │
    └── security-group/
        ├── main.tf            # Security group resource definition
        ├── variables.tf       # Module inputs
        ├── outputs.tf         # Module outputs
        └── README.md          # Module documentation
```

### Answer: Difference Between Root Module and Child Module

| Aspect | Root Module | Child Module |
|--------|------------|--------------|
| **Location** | Project root | `./modules/` subdirectory |
| **Purpose** | Orchestrates the full infrastructure | Encapsulates specific resources |
| **Calls** | Calls child modules | Called by root module |
| **State File** | Single shared state file | No separate state (part of root) |
| **Variables** | From CLI, files, environment | From calling module (root) |
| **Execution** | `terraform apply` here | Never direct `terraform apply` |
| **Reusability** | Project-specific | Can be used in multiple projects |
| **Example** | Defines VPC, calls vpc module | Defines just security group |

### Why This Structure Matters

```
Benefits of Modular Architecture:
✅ DRY Principle (Don't Repeat Yourself)
   - Write security group module once, use in 10 projects

✅ Maintainability
   - Fix a bug in ec2-instance module, all projects benefit

✅ Team Collaboration
   - Different teams own different modules
   - Platform team owns networking module
   - App team uses it without understanding details

✅ Testing
   - Test modules independently
   - Compose trusted modules for complex infrastructure

✅ Versioning
   - Modules can be versioned independently
   - Use specific module versions in different projects

✅ Scaling
   - Easy to add new resources
   - Easy to replicate patterns
```

---

## Task 2: Build a Custom EC2 Module

### Module Purpose
The EC2 module encapsulates the complexity of creating an EC2 instance with:
- AMI selection
- Instance type configuration
- Network setup (subnet, security groups)
- Tagging strategy

### Module Files

**File: `modules/ec2-instance/variables.tf`**
```hcl
variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
  # No default - REQUIRED input
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Sensible default
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
  # No default - REQUIRED input
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  # No default - REQUIRED input
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  # No default - REQUIRED input
}

variable "tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}  # Optional - allows extra tags
}
```

**File: `modules/ec2-instance/main.tf`**
```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  # Smart tagging: merge Name tag with additional tags
  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags  # Allows callers to add extra tags
  )
}
```

**File: `modules/ec2-instance/outputs.tf`**
```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "instance_arn" {
  description = "ARN of the instance"
  value       = aws_instance.this.arn
}
```

### Key Design Decisions

1. **Resource Naming**: Used `aws_instance.this` instead of a specific name
   - "this" is a convention for "the main resource in this module"
   - Makes modules more reusable

2. **Tag Strategy**: Used `merge()` function
   - Ensures Name tag is always set
   - Allows callers to add custom tags
   - No tag conflicts

3. **Variable Defaults**: Strategic defaults
   - `instance_type` has a default (t2.micro is safe)
   - `ami_id` is required (no reasonable default)
   - `tags` defaults to empty map (optional)

---

## Task 3: Build a Custom Security Group Module

### Module Purpose
The security group module demonstrates Terraform's `dynamic` blocks -- a powerful feature for generating repeated nested blocks from lists.

### Understanding Dynamic Blocks

Without dynamic block (repetitive):
```hcl
resource "aws_security_group" "this" {
  # ... other config ...
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ... repeated for each port!
}
```

With dynamic block (DRY):
```hcl
resource "aws_security_group" "this" {
  # ... other config ...
  
  dynamic "ingress" {
    for_each = var.ingress_ports  # [22, 80, 443]
    content {
      from_port   = ingress.value  # 22, then 80, then 443
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

### Module Files

**File: `modules/security-group/variables.tf`**
```hcl
variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
  # REQUIRED
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  # REQUIRED
}

variable "ingress_ports" {
  description = "List of ingress ports to allow"
  type        = list(number)
  default     = [22, 80]  # Sensible defaults
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}  # Optional
}
```

**File: `modules/security-group/main.tf`**
```hcl
resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group created by Terraform module"
  vpc_id      = var.vpc_id

  # Dynamic block: generates one ingress rule per port
  dynamic "ingress" {
    for_each = var.ingress_ports  # Iterate over list [22, 80, 443]
    content {
      from_port   = ingress.value    # Current port from iteration
      to_port     = ingress.value    # e.g., 22, 80, 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.sg_name
    },
    var.tags
  )
}
```

**File: `modules/security-group/outputs.tf`**
```hcl
output "sg_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "sg_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.this.arn
}

output "sg_name" {
  description = "Name of the security group"
  value       = aws_security_group.this.name
}
```

### Dynamic Block Anatomy

```
dynamic "ingress" {
  ↑           ↑
  |           └─ The nested block type to generate
  └───────────── "dynamic" keyword

  for_each = var.ingress_ports
  ↑        ↑
  |        └─ The list/map to iterate over
  └───────── for_each (iterate once per item)

  content {
    from_port   = ingress.value  ← access current item
    to_port     = ingress.value
    ...
  }
}
```

**How iteration works:**
```
Input:  var.ingress_ports = [22, 80, 443]

Iteration 1: ingress.key=0, ingress.value=22
  → Creates: ingress rule for port 22

Iteration 2: ingress.key=1, ingress.value=80
  → Creates: ingress rule for port 80

Iteration 3: ingress.key=2, ingress.value=443
  → Creates: ingress rule for port 443
```

---

## Task 4: Call Your Modules from Root

### Root Configuration

**File: `main.tf`**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Define common tags once, use everywhere
locals {
  common_tags = {
    Project     = "TerraformWeek"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Create Security Group using custom module
module "web_sg" {
  source = "./modules/security-group"

  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}

# Deploy Web Server using EC2 module
module "web_server" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

# Deploy API Server - SAME module, different inputs
module "api_server" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

### Module Block Anatomy

```hcl
module "web_sg" {              # Block name (used in state and outputs)
  source = "./modules/security-group"  # Path to module (local or remote)
  
  # Pass inputs to module
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}

# Access module outputs
module.web_sg.sg_id  ← Reference security group ID in other resources
module.web_server.public_ip  ← Get web server's public IP
module.api_server.instance_id  ← Get API server's instance ID
```

### Deployment with Modules

```bash
# Initialize - downloads/links local modules
terraform init

# Plan - shows all resources created by module calls
terraform plan

# Sample plan output:
# module.web_sg.aws_security_group.this will be created
# module.web_server.aws_instance.this will be created
# module.api_server.aws_instance.this will be created

# Apply
terraform apply

# Verify in state
terraform state list
# Shows:
# module.web_sg.aws_security_group.this
# module.web_server.aws_instance.this
# module.api_server.aws_instance.this
```

### Root Outputs

**File: `outputs.tf`**
```hcl
output "web_server_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "Public IP of the API server"
  value       = module.api_server.public_ip
}

# More outputs defined in actual file...
```

### Verification

After applying:
```bash
# Check running instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]'

# Sample output:
# [
#     ["i-0123456789abcdef0", "terraweek-web", "running"],
#     ["i-0987654321fedcba0", "terraweek-api", "running"]
# ]

# Both use the same security group
aws ec2 describe-security-groups --filters "Name=group-name,Values=terraweek-web-sg"

# Check tags
terraform output
# Shows: web_server_ip and api_server_ip
```

---

## Task 5: Use a Public Registry Module

### Why Use Registry Modules?

```
Custom VPC Module (what we COULD write):
├── VPC resource
├── Subnets (public & private)
├── Internet Gateway
├── NAT Gateway (optional)
├── Route tables & associations
├── VPC endpoints
├── Flow logs
└── ~200+ lines of code
└── Needs testing and maintenance

Official Registry Module (what we USE):
└── 1 module block calling terraform-aws-modules/vpc
└── ~10 lines of code
└── Tested by thousands of users
└── Security vetted
└── Best practices built-in
```

### Using Official VPC Module

**Official Module Source:**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}
```

### Module Source Formats

| Source | Example | Use Case |
|--------|---------|----------|
| Local Path | `./modules/ec2` | Your own modules |
| Registry | `terraform-aws-modules/vpc/aws` | Official public modules |
| GitHub | `github.com/owner/repo//modules/vpc` | Private repos |
| Git | `git::https://github.com/owner/repo.git` | Version control |
| S3 | `s3::https://bucket.s3.amazonaws.com/module.zip` | Private modules |

### Accessing Registry Module Outputs

```hcl
# In EC2 module calls, reference the VPC module outputs:

module "web_server" {
  source = "./modules/ec2-instance"
  
  subnet_id = module.vpc.public_subnets[0]    # Array of public subnets
  # OR
  subnet_id = module.vpc.private_subnets[1]   # Array of private subnets
}
```

### Registry Module Resource Comparison

```bash
# Check what the official VPC module creates
terraform init
terraform plan

# Example output:
# module.vpc.aws_vpc.this[0] will be created
# module.vpc.aws_subnet.public[0] will be created
# module.vpc.aws_subnet.public[1] will be created
# module.vpc.aws_subnet.private[0] will be created
# module.vpc.aws_subnet.private[1] will be created
# module.vpc.aws_internet_gateway.this[0] will be created
# module.vpc.aws_route_table.public[0] will be created
# module.vpc.aws_route_table_association.public[0] will be created
# module.vpc.aws_route_table_association.public[1] will be created
# ... many more resources for routing, NAT, etc.

# Count the resources created:
# The module creates ~15-20 resources with just 10 lines of config!
```

### Answer: Where are Registry Modules Downloaded?

```bash
# After terraform init, modules appear in:
.terraform/modules/

# Directory structure:
.terraform/modules/
├── vpc/
│   ├── modules/
│   │   ├── nat_gateway/
│   │   ├── vpc/
│   │   ├── security_group/
│   │   └── ...
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── modules.json   # Metadata file

# The modules.json tracks:
{
  "Modules": [
    {
      "Key": "vpc",
      "Source": "terraform-aws-modules/vpc/aws",
      "Version": "5.0.0",
      "Dir": ".terraform/modules/vpc"
    }
  ]
}
```

### Exploring a Downloaded Module

```bash
# View module contents
tree .terraform/modules/vpc/

# Read module documentation
cat .terraform/modules/vpc/README.md

# Check module variables
cat .terraform/modules/vpc/variables.tf

# See available outputs
cat .terraform/modules/vpc/outputs.tf
```

---

## Task 6: Module Versioning and Best Practices

### Version Constraint Syntax

```hcl
# Exact version - most restrictive
version = "5.1.0"
└─ Only 5.1.0 is allowed
└─ Safe but no bug fixes from newer patches

# Pessimistic constraint - recommended
version = "~> 5.0"
└─ Allows: 5.0.0, 5.1.0, 5.2.0, 5.100.0
└─ Blocks: 4.x, 6.x
└─ Good: bug fixes, same major version

# Caret constraint - major only
version = "^5.0"
└─ Same as ~> 5.0 for versions < 1.0.0
└─ Different behavior for versions >= 1.0.0

# Specific constraint - flexible
version = ">= 5.0, < 6.0"
└─ Allows anything from 5.0 to 5.99.99
└─ Maximum flexibility

# Greater than
version = ">= 5.0"
└─ Any version 5.0 or higher
└─ Least restrictive - not recommended

# Less restrictive (not recommended)
version = "*"
└─ Any version - unpredictable
└─ Never use in production
```

### Checking for Module Updates

```bash
# Check if newer versions are available
terraform init -upgrade

# This downloads newer versions matching your constraints
# Example:
# Downloading terraform-aws-modules/vpc/aws 5.0.0 -> 5.2.0

# View current state
terraform state show module.vpc
```

### Module Versioning Best Practices

```
1. Pin to Pessimistic Constraint (~>)
   ├─ Provides automatic bug fix updates
   ├─ Prevents breaking changes
   └─ Sweet spot for production

2. Lock File Strategy
   ├─ Commit .terraform.lock.hcl to git
   ├─ Ensures reproducible infrastructure
   ├─ Team consistency
   └─ Version audit trail

3. Testing Before Upgrade
   ├─ Develop in non-prod with latest
   ├─ Run full test suite
   ├─ Stage to QA before prod
   └─ Plan before applying

4. Version Constraints by Environment
   └─ Dev: ~> 5.0  (latest within major)
   └─ Staging: >= 5.0, < 5.5  (more constrained)
   └─ Prod: = 5.1.0  (exact version)

5. Module Governance
   ├─ Standardize on approved modules
   ├─ Only use terraform-aws-modules registry
   ├─ Block custom modules from untrusted sources
   └─ Require module reviews
```

### Module Discovery and Registry

```bash
# Search Terraform Registry
# https://registry.terraform.io/

# Command-line search (requires Terraform 0.13+)
terraform providers   # Lists required providers
terraform state list  # Shows what's managed

# Verify module source
cat .terraform/modules.json
```

---

## Complete Module Usage Summary

### Quick Reference

```hcl
# 1. LOCAL MODULE (custom)
module "web_sg" {
  source = "./modules/security-group"
  vpc_id = aws_vpc.main.id
}

# 2. REGISTRY MODULE (official)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "my-vpc"
}

# 3. REMOTE MODULE (GitHub)
module "iam_role" {
  source = "github.com/owner/terraform-aws-iam//modules/iam-role"
  version = "~> 2.0"
}

# 4. ACCESSING OUTPUTS
resource "aws_instance" "this" {
  subnet_id = module.vpc.public_subnets[0]
}

# 5. STATE MANAGEMENT
# Modules don't have separate state files
# Everything goes to root state: terraform.tfstate
terraform state list
# Shows: module.vpc.aws_vpc.this, module.web_sg.aws_security_group.this
```

---

## Common Module Patterns

### Pattern 1: Reusable Compute Module
```hcl
module "app_servers" {
  for_each = var.environments  # { dev = {}, prod = {} }
  
  source = "./modules/ec2-instance"
  instance_name = "app-${each.key}"
  instance_type = each.value.type
}

# Creates: app-dev, app-prod instances
```

### Pattern 2: Multi-Environment Deployment
```hcl
locals {
  environments = {
    dev  = { instance_type = "t2.micro", count = 1 }
    prod = { instance_type = "t3.large", count = 3 }
  }
}

module "environment" {
  for_each = local.environments
  
  source = "./modules/environment"
  env_name = each.key
  instance_type = each.value.instance_type
  instance_count = each.value.count
}
```

### Pattern 3: Shared Module Library
```
git repo: terraform-modules (organization)
├── modules/
│   ├── vpc/
│   ├── networking/
│   ├── security/
│   ├── compute/
│   └── database/
├── examples/
└── tests/

# Used in other projects:
module "vpc" {
  source = "github.com/myorg/terraform-modules//modules/vpc?ref=v2.0.0"
}
```

---

## Troubleshooting Modules

### Issue: Module not found
```bash
Error: Failed to download module

Solution:
terraform init -upgrade
terraform get
```

### Issue: Outputs not available
```bash
Error: output not found

Solution: Check module outputs
cat modules/ec2-instance/outputs.tf
terraform output module_name  # View module outputs
```

### Issue: State conflicts
```bash
Error: resource already managed elsewhere

Solution:
terraform state list  # Find conflicting resource
terraform state show <resource>  # Details
terraform state mv <old> <new>   # Reorganize if needed
```

---

## Module Checklist

Before publishing a module:

```
✅ Inputs defined with descriptions and types
✅ Outputs defined for all useful values
✅ Default values for optional inputs
✅ Resource naming convention ("this")
✅ Tagging strategy with merge()
✅ README.md with examples
✅ Variables validated (required inputs clear)
✅ Works with different AWS regions
✅ Tested with terraform validate and fmt
✅ No hardcoded values (all variables)
✅ Follows naming conventions
✅ Version compatibility documented
```

---

## Key Takeaways

1. **Modules = Functions**: Reusable, composable infrastructure code
2. **Root vs Child**: Root calls children; children have no separate state
3. **Dynamic Blocks**: Generate repeated nested blocks from lists
4. **Registry Modules**: Use official modules for complex infrastructure
5. **Version Constraints**: Use `~>` for sensible automatic updates
6. **Module Outputs**: Access via `module.name.output_name`
7. **Tagging**: Use `merge()` for flexible tag strategies
8. **Reusability**: Write once, call with different inputs multiple times
9. **Testing**: Test modules independently before composition
10. **Documentation**: READMEs and clear variable descriptions essential

---

## Resources

- [Terraform Modules Documentation](https://www.terraform.io/language/modules)
- [Module Best Practices](https://www.terraform.io/language/modules/develop)
- [Terraform Registry](https://registry.terraform.io/)
- [terraform-aws-modules/vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [Dynamic Blocks](https://www.terraform.io/language/dynamic-blocks)
- [Module Sources](https://www.terraform.io/language/modules/sources)

