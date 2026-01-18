# Terraform configuration for AWS infrastructure
# This is optional - you can use AWS Console or CLI instead

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

# RDS PostgreSQL Database
resource "aws_db_instance" "postgres" {
  identifier             = "nonprofit-learning-db"
  engine                 = "postgres"
  engine_version         = "14.9"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp2"
  storage_encrypted       = true
  
  db_name  = "nonprofit_learning"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "nonprofit-learning-final-snapshot"
  
  tags = {
    Name = "Nonprofit Learning Database"
  }
}

# Get default VPC
data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

# Get VPC by ID if provided
data "aws_vpc" "selected" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

locals {
  vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
  vpc_cidr = var.vpc_id != "" ? data.aws_vpc.selected[0].cidr_block : data.aws_vpc.default[0].cidr_block
}

# Get subnets in the VPC
data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

# Use provided subnets or get default subnets
locals {
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.vpc_subnets.ids
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "nonprofit-learning-db-subnet-group"
  subnet_ids = local.subnet_ids
  
  tags = {
    Name = "Nonprofit Learning DB Subnet Group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "nonprofit-learning-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = local.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
    description = "PostgreSQL access from VPC"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
  
  tags = {
    Name = "Nonprofit Learning RDS Security Group"
  }
}

# ECR Repository for Backend
resource "aws_ecr_repository" "backend" {
  name                 = "nonprofit-learning-backend"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Name = "Nonprofit Learning Backend"
  }
}

# S3 Bucket for Frontend
resource "aws_s3_bucket" "frontend" {
  bucket = "nonprofit-learning-frontend"
  
  tags = {
    Name = "Nonprofit Learning Frontend"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3-nonprofit-learning-frontend"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-nonprofit-learning-frontend"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name = "Nonprofit Learning Frontend"
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for Nonprofit Learning Frontend"
}
