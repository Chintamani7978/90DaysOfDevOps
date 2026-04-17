# Default development environment values
project_name  = "terraweek"
environment   = "dev"
instance_type = "t2.micro"
region        = "us-east-1"

# Override default CIDR blocks if needed
# vpc_cidr    = "10.0.0.0/16"
# subnet_cidr = "10.0.1.0/24"

# Additional tags
extra_tags = {
  CostCenter = "Engineering"
  Owner      = "DevOps"
}
