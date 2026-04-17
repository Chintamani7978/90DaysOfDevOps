# Day 63: Variables, Outputs, Data Sources and Expressions - Solution

## Documentation

### Question 1: The Five Variable Types in Terraform

Terraform has five primitive types and two complex types:

#### Primitive Types:
1. **string**: Text values
   ```hcl
   variable "instance_type" {
     type = string
     default = "t2.micro"
   }
   ```

2. **number**: Integer or floating-point numbers
   ```hcl
   variable "instance_count" {
     type = number
     default = 3
   }
   ```

3. **bool**: true or false
   ```hcl
   variable "enable_monitoring" {
     type = bool
     default = true
   }
   ```

#### Complex Types:
4. **list**: Ordered collection (list of any single type)
   ```hcl
   variable "allowed_ports" {
     type = list(number)
     default = [22, 80, 443]
   }
   ```

5. **map**: Key-value pairs (all values same type)
   ```hcl
   variable "extra_tags" {
     type = map(string)
     default = {
       Environment = "dev"
       Owner = "team"
     }
   }
   ```

#### Advanced Types:
- **set**: Like list but unordered and unique
- **object**: Structured mapping with typed fields
- **tuple**: Like list but can have different types

### Question 2: Variable Precedence (Lowest to Highest Priority)

Variable values can come from multiple sources. Terraform applies them in this order:

1. **Default values** in variable blocks (lowest priority)
   ```hcl
   variable "env" {
     default = "dev"
   }
   ```

2. **Environment variables** (`TF_VAR_*`)
   ```bash
   export TF_VAR_environment="staging"
   ```

3. **`.tfvars` files** (in order: auto-loaded, then specified)
   ```bash
   # Auto-loads terraform.tfvars
   terraform plan
   
   # Explicit file
   terraform plan -var-file="prod.tfvars"
   ```

4. **CLI flags** `-var` (highest priority)
   ```bash
   terraform plan -var="instance_type=t2.nano"
   ```

**Highest Priority**: CLI `-var` flags override everything.

### Using Variable Precedence

```bash
# The ultimate precedence test:
export TF_VAR_instance_type="t2.nano"           # 2nd priority
terraform plan \
  -var-file="prod.tfvars" \                      # 3rd priority (if it has instance_type)
  -var="instance_type=t2.medium"                 # 1st priority - WINS!
```

In this example: `t2.medium` is used (CLI flag wins).

## Key Implementation Details

### Dynamic Ingress Rules (Day 63 Solution)

The `main.tf` uses a `dynamic` block to create security group rules for all allowed ports:

```hcl
dynamic "ingress" {
  for_each = var.allowed_ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Benefits:
- No need to hardcode each port
- Easy to add new ports via `allowed_ports` variable
- Scales automatically with list length

### Common Tags Pattern

The solution uses a `locals` block to merge tags:

```hcl
locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.extra_tags
  )
}
```

Then applied to all resources:
```hcl
tags = merge(
  local.common_tags,
  { Name = "${var.project_name}-vpc-${var.environment}" }
)
```

### Environment-Specific Configs

Compare `terraform.tfvars` (dev) vs `prod.tfvars`:

**Development** (terraform.tfvars):
- Instance type: `t2.micro`
- VPC CIDR: `10.0.0.0/16`
- Extra tags: CostCenter = Engineering

**Production** (prod.tfvars):
- Instance type: `t3.small` (more resources)
- VPC CIDR: `10.1.0.0/16` (network isolation)
- Extra tags: BackupPolicy = daily

## Running the Solution

```bash
# Initialize
terraform init

# Dev environment (uses terraform.tfvars automatically)
terraform plan

# Production environment (explicit file)
terraform plan -var-file="prod.tfvars"

# Override a single variable
terraform apply -var="instance_type=t2.small"

# View outputs
terraform apply
terraform output vpc_id
terraform output -json

# All outputs as JSON
terraform output -json > outputs.json
```

## Variable Validation Examples

The `variables.tf` includes validations:

```hcl
# CIDR validation
validation {
  condition     = can(cidrhost(var.vpc_cidr, 0))
  error_message = "VPC CIDR must be a valid CIDR block."
}

# Instance type validation
validation {
  condition     = can(regex("^[a-z][0-9][a-z]?\\..*$", var.instance_type))
  error_message = "Instance type must be a valid format."
}

# Port range validation
validation {
  condition     = alltrue([for port in var.allowed_ports : port >= 1 && port <= 65535])
  error_message = "All ports must be between 1 and 65535."
}
```

These prevent invalid inputs before applying infrastructure.

## Best Practices for Variables

1. **Always use defaults** for optional variables
2. **Never hardcode** infrastructure values
3. **Group related variables** in files (variables.tf, networking.tf, compute.tf)
4. **Add descriptions** for every variable
5. **Use `.tfvars`** for environment-specific values
6. **Validate inputs** to catch errors early
7. **Use outputs** to expose important information
8. **Document outputs** with descriptions for consumers

## Notes on Data Sources

This solution uses two data sources:

1. **`data.aws_availability_zones`**: Dynamically finds available zones in the region
2. **`data.aws_ami`**: Finds the latest Amazon Linux 2 AMI automatically

This makes the config portable across regions without manual AMI ID lookups.
