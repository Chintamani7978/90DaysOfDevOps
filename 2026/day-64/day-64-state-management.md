# Day 64 - Terraform State Management and Remote Backends

## Overview
This document covers Terraform state management best practices, including local vs remote backends, state locking, importing resources, and drift management.

---

## Task 1: Inspect Your Current State

### Answers to Questions:

**1. How many resources does Terraform track?**
```
Answer: Terraform tracks 10 resources in this configuration:
- 1 VPC (aws_vpc.main)
- 1 Public Subnet (aws_subnet.public)
- 1 Internet Gateway (aws_internet_gateway.main)
- 1 Route Table (aws_route_table.public)
- 1 Route Table Association (aws_route_table_association.public)
- 1 Security Group (aws_security_group.main)
- 1 EC2 Instance (aws_instance.web)
- 1 S3 Bucket (aws_s3_bucket.test_bucket)
- 1 S3 Bucket Versioning (aws_s3_bucket_versioning.test_bucket)
- 2 Data sources (aws_ami.amazon_linux, aws_caller_identity.current, aws_availability_zones.available)

Total: 10 managed resources + 3 data sources
```

**2. What attributes does the state store for an EC2 instance?**
```
Answer: The state stores FAR MORE attributes than what you define in the .tf file:
- Instance metadata (ID, ARN, availability zone)
- Network configuration (VPC ID, subnet ID, security group IDs, ENI details)
- Block device mappings
- IAM instance profile
- Monitoring configuration
- CPU options
- EBS optimization settings
- Tenancy information
- Public/Private IP addresses
- Source/destination check settings
- Root block device details
- Key pair name
- Launch time and state
- Credit specifications (for T2 instances)
- Hibernation options
- And dozens more...

This is why state files are so important -- they capture the COMPLETE configuration 
of resources as they actually exist in AWS, not just what you specified in code.
```

**3. What does the serial number in terraform.tfstate represent?**
```
Answer: The "serial" number is a version counter that increments with each 
terraform apply operation. It serves as:
- An audit trail of state file modifications
- A safety mechanism to detect concurrent operations
- A way to identify if state was modified outside of Terraform
- A recovery checkpoint for versioning systems

Example: If serial = 3, the state has been modified 3 times by terraform apply.
```

### Commands Reference:
```bash
# View full state in human-readable format
terraform show

# List all managed resources
terraform state list

# Show specific resource attributes
terraform state show aws_instance.web
terraform state show aws_vpc.main

# View local terraform.tfstate file
cat terraform.tfstate | grep '"serial"'
```

---

## Task 2: Set Up S3 Remote Backend

### Step 1: Create Backend Infrastructure

First, create the S3 bucket and DynamoDB table using AWS CLI:

```bash
# Set your unique identifier
export NAME=terraweek-dev

# Create S3 bucket with versioning
aws s3api create-bucket \
  --bucket terraweek-state-${NAME} \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraweek-state-${NAME} \
  --versioning-configuration Status=Enabled

# Block public access (security best practice)
aws s3api put-public-access-block \
  --bucket terraweek-state-${NAME} \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraweek-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

### Step 2: Add Backend Configuration

Uncomment the backend block in `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraweek-state-yourname"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

### Step 3: Migrate State to S3

```bash
terraform init
# When prompted: "Do you want to copy existing state to the new backend?"
# Answer: yes
```

### Step 4: Verification

```bash
# Check S3 bucket
aws s3 ls s3://terraweek-state-yourname/

# Verify state file is there
aws s3 ls s3://terraweek-state-yourname/dev/

# Run plan - should show no changes
terraform plan
```

### Key Benefits of S3 Remote Backend:
✅ **Durability**: S3 replicates across multiple availability zones
✅ **Versioning**: Recover previous state versions if needed
✅ **Encryption**: State encrypted at rest
✅ **Locking**: DynamoDB prevents concurrent modifications
✅ **Collaboration**: Team members access the same source of truth
✅ **Backup**: Easier to implement backup policies

---

## Task 3: Test State Locking

### Why Locking Matters:
State locking prevents race conditions when multiple team members run `terraform apply` simultaneously. Without locking, state file corruption is inevitable in team environments.

### Testing Procedure:

**Terminal 1:**
```bash
terraform apply
# Terraform waits for confirmation - DO NOT PRESS YES YET
```

**Terminal 2 (while Terminal 1 is waiting):**
```bash
terraform plan
```

**Expected Output in Terminal 2:**
```
Error: Error acquiring the state lock

Error: error acquiring the lock: ConditionalCheckFailedException: 
The conditional request failed

Lock Info:
  ID:        <LOCK_ID>
  Path:      terraweek-state-yourname/dev/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.5.0
  Created:   <TIMESTAMP>
  Info:
```

### Critical for Team Environments:
```
Why locking is essential:
1. Prevents two applies from running simultaneously
2. Avoids corrupting the state file
3. Ensures sequential, ordered changes
4. Protects against accidental overwrites
5. Required for CI/CD pipelines
```

### Force Unlock (Use with Caution!):
```bash
# Only use if you are ABSOLUTELY SURE no operation is running
terraform force-unlock <LOCK_ID>
```

---

## Task 4: Import an Existing Resource

### Scenario:
You have infrastructure created manually (through AWS console) that needs to be managed by Terraform.

### Steps:

**Step 1: Create resource manually**
```bash
# Create an S3 bucket in AWS console or CLI
aws s3api create-bucket \
  --bucket terraweek-import-test-yourname \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

**Step 2: Add resource block to Terraform (without implementation details)**
```hcl
# In main.tf - add this empty block
resource "aws_s3_bucket" "imported" {
  # Will be filled by import
}
```

**Step 3: Import the resource**
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-yourname
```

**Step 4: Complete the configuration**
```bash
# Run plan to see what's missing
terraform plan

# Update the resource block until plan shows "No changes"
```

**Step 5: Verify**
```bash
terraform state list | grep imported
terraform state show aws_s3_bucket.imported
```

### Answer: Difference between terraform import and creating from scratch

| Aspect | terraform import | Create from scratch |
|--------|------------------|-------------------|
| **Source** | Pre-existing AWS resource | Defined in .tf files |
| **Process** | Read real AWS resource → Add to state | Define code → Apply to create |
| **Risk** | Low risk (doesn't modify AWS) | Normal terraform risk |
| **Time** | Fast (query AWS API) | Depends on resource creation time |
| **When to use** | Legacy infrastructure, manual resources | New projects, IaC from start |
| **Verification** | Must match reality immediately | Create and validate |

---

## Task 5: State Surgery - mv and rm

### Use Case 1: Rename a Resource in State
```bash
# Rename in state
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket

# Update the .tf file to match
# From: resource "aws_s3_bucket" "imported"
# To:   resource "aws_s3_bucket" "logs_bucket"

# Verify
terraform plan  # Should show "No changes"
```

**When to use `state mv`:**
- Reorganizing code structure without destroying resources
- Splitting monolithic modules into smaller ones
- Renaming resources for clarity without re-creating them

### Use Case 2: Remove Resource from State (Without Destroying)
```bash
# Remove from state (AWS resource still exists)
terraform state rm aws_s3_bucket.logs_bucket

# Verify it's gone from state
terraform state list | grep logs_bucket  # Should return nothing

# Run plan - Terraform no longer knows about it
terraform plan  # Will show no changes
```

**When to use `state rm`:**
- Removing resources from Terraform management
- Migrating to different IaC tool
- Cleaning up orphaned state entries
- Managing manually-created resources outside Terraform

### Use Case 3: Re-import to Bring Back to Management
```bash
# Re-import the same resource
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-yourname

# Resource is back under Terraform management
terraform state list | grep logs_bucket
```

**Real-world Example:**
```
Scenario: Your team wants to manage EC2 instances with Terraform,
but some instances were created manually. You:
1. Use `terraform import` to add them to state
2. As you refactor, use `state mv` to reorganize them into modules
3. When decommissioning, use `state rm` to stop managing them (but keep the instances running for migration)
4. Then manually delete the instances after verifying they're not needed
```

---

## Task 6: Simulate and Fix State Drift

### What is State Drift?
State drift occurs when infrastructure in AWS changes outside of Terraform -- through:
- Manual console changes
- AWS CLI commands by other tools
- Third-party automation
- Someone else's manual modifications

### Simulation Steps:

**Step 1: Ensure everything is in sync**
```bash
terraform apply
terraform plan  # Should show "No changes"
```

**Step 2: Manually change resource in AWS**
```bash
# Option A: Change EC2 instance name tag via AWS console
# Option B: Use AWS CLI
aws ec2 create-tags \
  --resources <instance-id> \
  --tags Key=Name,Value=ManuallyChanged \
  --region ap-south-1
```

**Step 3: Detect the drift**
```bash
terraform plan
```

**Expected Output:**
```
resource "aws_instance" "web" {
  tags = {
    - "Name" = "terraweek-instance" -> null
    + "Name" = "ManuallyChanged"
  }
}

Plan: 0 to add, 1 to modify, 0 to destroy.
```

### Resolution: Two Approaches

**Option A: Reconcile (Force reality to match config)**
```bash
# Terraform overrides the manual change
terraform apply

# Verify
terraform plan  # Shows "No changes"
```

**Option B: Accept drift (Update code to match reality)**
```hcl
# Update main.tf
resource "aws_instance" "web" {
  # ... other config ...
  tags = {
    Name = "ManuallyChanged"  # Accept the new value
  }
}

# Then apply
terraform apply
```

### How to Prevent Drift in Production:

```
Best Practices:
✅ 1. Restrict AWS console access for production
✅ 2. Require all changes through CI/CD (terraform apply only)
✅ 3. Implement approval workflows for applies
✅ 4. Regular drift detection (scheduled terraform plan)
✅ 5. Audit logging for all infrastructure changes
✅ 6. Separate environments (dev/staging/prod)
✅ 7. Enforce code reviews for all Terraform changes
✅ 8. Use terraform refresh to detect drift:
   terraform refresh           # Update state without changes
   terraform plan -refresh=true  # Always refresh before planning
```

### Drift Detection Script (Scheduled Job):
```bash
#!/bin/bash
# Run this daily to detect drift
terraform refresh
terraform plan -no-color > /tmp/drift-report.txt

if grep -q "Plan:" /tmp/drift-report.txt; then
  echo "DRIFT DETECTED!" | mail -s "Terraform Drift Alert" ops@company.com
  cat /tmp/drift-report.txt >> /tmp/drift-report.txt
fi
```

---

## Architecture Diagram: Local vs Remote State

```
LOCAL STATE (NOT RECOMMENDED)
┌─────────────────────────────┐
│  Developer's Machine        │
│  ┌───────────────────────┐  │
│  │ terraform.tfstate     │  │
│  │ (Single point of      │  │
│  │  failure)             │  │
│  └───────────────────────┘  │
│  ❌ No backup              │
│  ❌ No sharing             │
│  ❌ No locking             │
│  ❌ Data loss risk         │
└─────────────────────────────┘


REMOTE STATE (RECOMMENDED)
┌──────────────────────────────────────────────────────────┐
│                  AWS Account                              │
│  ┌──────────────────────┐    ┌────────────────────────┐  │
│  │  S3 Bucket           │◄───┤  DynamoDB Table        │  │
│  │ (State Storage)      │    │  (State Locking)       │  │
│  │                      │    │                        │  │
│  │ ✅ Versioning       │    │ ✅ Prevents concurrent │  │
│  │ ✅ Encryption       │    │    applies            │  │
│  │ ✅ Replication      │    │ ✅ Audit logging      │  │
│  │ ✅ Access control   │    │ ✅ Team-friendly      │  │
│  └──────────────────────┘    └────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
         ▲                    ▲
         │                    │
    ┌────┴────┬───────────┬───┴────┐
    │          │           │        │
  Dev1        Dev2        CI/CD    Ops
  Laptop      Laptop      Pipeline  Laptop
  (Shared state for all team members)
```

---

## Summary Table: State Management Commands

| Command | Purpose | Risk Level |
|---------|---------|-----------|
| `terraform show` | View state in readable format | Safe (read-only) |
| `terraform state list` | List all resources | Safe (read-only) |
| `terraform state show <resource>` | Show resource details | Safe (read-only) |
| `terraform refresh` | Update state from AWS | Medium (modifies state) |
| `terraform state mv` | Rename resources | Medium (reorganizes) |
| `terraform state rm` | Remove from state | High (stops management) |
| `terraform import` | Add existing resource | High (modifies state) |
| `terraform force-unlock` | Clear lock | Critical (use with care) |

---

## Key Takeaways

1. **State is Critical**: Terraform state is the single source of truth
2. **Use Remote Backends**: S3 + DynamoDB for production
3. **Enable Locking**: Prevents concurrent modifications
4. **Version Control**: Keep S3 versioning enabled
5. **Encryption**: Always encrypt state at rest
6. **Import Strategically**: Gradually bring manual resources under Terraform management
7. **Monitor Drift**: Schedule regular `terraform plan` runs
8. **Restrict Access**: Limit who can modify state directly
9. **Backup Strategy**: Regular backups of state files
10. **CI/CD First**: All changes through automated pipelines

---

## References

- [Terraform State Documentation](https://www.terraform.io/language/state)
- [Backend Configuration](https://www.terraform.io/language/settings/backends)
- [State Locking](https://www.terraform.io/language/state/locking)
- [Import Existing Resources](https://www.terraform.io/cli/import)
