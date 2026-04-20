terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after creating S3 bucket and DynamoDB table
  # backend "s3" {
  #   bucket         = "terraweek-state-yourname"
  #   key            = "dev/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraweek-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraweek-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "terraweek-public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraweek-igw"
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "terraweek-public-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create Security Group
resource "aws_security_group" "main" {
  name        = "terraweek-sg"
  description = "Security group for Terraform Week instance"
  vpc_id      = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraweek-sg"
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "terraweek-instance"
  }
}

# Create S3 Bucket for importing test
resource "aws_s3_bucket" "test_bucket" {
  bucket = "terraweek-state-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "terraweek-test-bucket"
  }
}

# Enable versioning on S3 bucket
resource "aws_s3_bucket_versioning" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
