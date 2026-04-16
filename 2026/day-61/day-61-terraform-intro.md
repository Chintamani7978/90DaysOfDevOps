# Day 61: Introduction to Terraform and Your First AWS Infrastructure

## Task Completion Summary
Date Completed: [Date]  
Region: [Your AWS Region]  
S3 Bucket Name: [Your bucket name]  
EC2 Instance ID: [Your instance ID]

---

## 1. Infrastructure as Code (IaC) - Explanation

**What is IaC and why does it matter in DevOps?**

[Write here: Explain IaC in your own words. Include why it matters for DevOps teams. 3-4 sentences.]

**Problems IaC solves compared to manual console operations:**
- [Point 1]
- [Point 2]
- [Point 3]

**How Terraform differs from other tools:**

| Tool | Key Difference |
|------|---|
| AWS CloudFormation | [Your explanation] |
| Ansible | [Your explanation] |
| Pulumi | [Your explanation] |

**Declarative & Cloud-Agnostic:**
- **Declarative**: [Your explanation of what this means]
- **Cloud-Agnostic**: [Your explanation of why this matters]

---

## 2. Installation & Configuration

### Terraform Installation
- **Terraform Version**: [Run `terraform -version` and paste output]
```
[Paste output here]
```

### AWS CLI Configuration
- **AWS Account ID**: [Run `aws sts get-caller-identity` and paste output]
```
[Paste output here]
```

---

## 3. Your First Terraform Config - S3 Bucket

### File: main.tf
```hcl
[Paste your main.tf content here]
```

### Terraform Init Output
```
[Paste the output of `terraform init`]
```

**What did `terraform init` download?**
[Your answer]

**What does the `.terraform/` directory contain?**
[Your answer]

### Screenshot: terraform apply (S3 Bucket)
![S3 Bucket Creation](./screenshots/terraform-apply-s3.png)
<!-- Take screenshot of successful terraform apply output -->

### Screenshot: AWS S3 Console
![S3 Console](./screenshots/aws-s3-console.png)
<!-- Take screenshot showing your bucket in AWS console -->

---

## 4. Add EC2 Instance

### Updated main.tf with EC2
```hcl
[Paste the EC2 resource section here]
```

### terraform plan Output
```
[Paste output showing EC2 to be created]
```

### Screenshot: terraform apply (EC2)
![EC2 Creation](./screenshots/terraform-apply-ec2.png)
<!-- Take screenshot of applying EC2 instance -->

### Screenshot: AWS EC2 Console
![EC2 Console](./screenshots/aws-ec2-console.png)
<!-- Take screenshot showing your instance with Name tag "TerraWeek-Day1" -->

**How does Terraform know which resources already exist?**
[Your answer - mention the state file]

---

## 5. Understanding the State File

### State File Contents
**What information does terraform.tfstate store?**
- [Point 1]
- [Point 2]
- [Point 3]

### Terraform State Commands

**terraform show** - Human-readable view of current state
```
[Paste output here]
```

**terraform state list** - List all managed resources
```
[Paste output here]
```

**terraform state show aws_s3_bucket.<name>** - Specific resource details
```
[Paste output here]
```

**terraform state show aws_instance.<name>** - Specific resource details
```
[Paste output here]
```

### Why is the State File Important?

**Why should you never manually edit the state file?**
[Your answer]

**Why should the state file NOT be committed to Git?**
[Your answer]

---

## 6. Modify, Plan, and Destroy

### Change Made
- Changed EC2 tag from `"TerraWeek-Day1"` to `"TerraWeek-Modified"`

### terraform plan Output
```
[Paste the plan output showing the change]
```

**What do the symbols mean in terraform plan?**
- `~` = [Your explanation]
- `+` = [Your explanation]
- `-` = [Your explanation]

**Is this an in-place update or destroy & recreate?**
[Your answer]

### terraform apply Output
```
[Paste the apply output]
```

### Screenshot: Updated EC2 Tag in Console
![Updated Instance Tag](./screenshots/updated-ec2-tag.png)
<!-- Take screenshot showing the modified tag in AWS console -->

### terraform destroy Output
```
[Paste the destroy output]
```

### Screenshot: Resources Destroyed
![Resources Destroyed](./screenshots/console-after-destroy.png)
<!-- Take screenshot showing empty S3 and EC2 consoles -->

---

## 7. Terraform Commands Reference

| Command | Purpose | Output |
|---------|---------|--------|
| `terraform init` | [Explain] | [What it returns] |
| `terraform plan` | [Explain] | [What it returns] |
| `terraform apply` | [Explain] | [What it returns] |
| `terraform destroy` | [Explain] | [What it returns] |
| `terraform show` | [Explain] | [What it returns] |
| `terraform state list` | [Explain] | [What it returns] |
| `terraform validate` | [Explain] | [What it returns] |
| `terraform fmt` | [Explain] | [What it returns] |

---

## 8. Key Learnings

### What I Learned Today:
1. [Learning point 1]
2. [Learning point 2]
3. [Learning point 3]
4. [Learning point 4]
5. [Learning point 5]

### Challenges Faced & How I Solved Them
- **Challenge 1**: [Description]
  - **Solution**: [How you fixed it]
  
- **Challenge 2**: [Description]
  - **Solution**: [How you fixed it]

### Important Notes for Future Reference
- [Note 1]
- [Note 2]
- [Note 3]

---

## 9. Files & Configuration

### .gitignore Entry
```
[Paste the entries you added]
```

### Project Directory Structure
```
terraform-basics/
├── main.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── .terraform/
├── .gitignore
└── day-61-terraform-intro.md
```

---

## 10. Learn in Public Share

**LinkedIn Post:**
"Started the TerraWeek Challenge day 1 -- installed Terraform, created my first S3 bucket and EC2 instance using code, and destroyed it all with one command. Infrastructure as Code just clicked. [Screenshot] #90DaysOfDevOps #TerraWeek #DevOpsKaJosh #TrainWithShubham"

---

## Submission Checklist
- [ ] All 6 challenge tasks completed
- [ ] Screenshots taken for all resource creations
- [ ] This markdown file completed with all sections filled
- [ ] File added to `2026/day-61/day-61-terraform-intro.md`
- [ ] Changes committed to Git
- [ ] LinkedIn post shared

---

*Generated with 90DaysOfDevOps Day 61 Challenge*
