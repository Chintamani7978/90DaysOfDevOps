# Production environment configuration
project_name  = "terraweek"
environment   = "prod"
instance_type = "t3.small"
region        = "us-east-1"

# Production network isolation
vpc_cidr    = "10.1.0.0/16"
subnet_cidr = "10.1.1.0/24"

# Additional tags for production
extra_tags = {
  CostCenter = "Production"
  Owner      = "Infrastructure"
  BackupPolicy = "daily"
}
