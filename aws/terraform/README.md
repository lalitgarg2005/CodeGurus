# Terraform Deployment Guide

This directory contains Terraform configuration to deploy the Nonprofit Learning Platform infrastructure to AWS.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** installed (v1.0+)
4. **AWS Credentials** with permissions for:
   - EC2 (create security groups, describe VPCs/subnets)
   - RDS (create database, subnet groups)
   - ECR (create repository)
   - S3 (create bucket, configure website)
   - CloudFront (create distribution)
   - VPC (read default VPC)
   
   **⚠️ Important**: If you get permission errors, see [IAM_PERMISSIONS.md](./IAM_PERMISSIONS.md) for detailed setup instructions.

## Quick Start

### 1. Configure AWS Credentials

```bash
# Option 1: Interactive configuration
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: AWS SSO
aws sso login
```

### 2. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
- `db_username`: Database master username (e.g., "postgres")
- `db_password`: **Secure password** for the database
- `aws_region`: AWS region (default: "us-east-1")

### 3. Deploy Infrastructure

**Option A: Using the deployment script (Recommended)**
```bash
./deploy.sh
```

**Option B: Manual deployment**
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment (preview changes)
terraform plan

# Apply changes
terraform apply
```

### 4. Get Outputs

After deployment, Terraform will output:
- RDS endpoint (database connection string)
- ECR repository URL
- S3 bucket name
- CloudFront distribution ID and domain

Save these values - you'll need them for:
- GitHub Secrets (`DATABASE_URL`)
- App Runner configuration
- Frontend environment variables

## What Gets Created

1. **RDS PostgreSQL Database**
   - Instance: db.t3.micro
   - Storage: 20GB (auto-scales to 100GB)
   - Encrypted at rest
   - Automated backups (7 days)

2. **ECR Repository**
   - For backend Docker images
   - Image scanning enabled

3. **S3 Bucket**
   - For frontend static files
   - Website hosting enabled

4. **CloudFront Distribution**
   - CDN for frontend
   - HTTPS enabled

5. **Security Groups**
   - RDS security group (PostgreSQL access from VPC)

## Configuration

### Using Default VPC (Recommended for Quick Start)

If you don't specify `vpc_id` or `subnet_ids`, Terraform will:
- Use your AWS account's default VPC
- Automatically find subnets in that VPC
- Create security groups in the default VPC

### Using Custom VPC

If you have a custom VPC:

```hcl
# In terraform.tfvars
vpc_id = "vpc-xxxxxxxxx"
subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
```

## Updating Infrastructure

```bash
# Make changes to .tf files
# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Destroying Infrastructure

⚠️ **Warning**: This will delete all resources including the database!

```bash
terraform destroy
```

## Troubleshooting

### Error: "ExpiredToken"
- Your AWS credentials expired
- Run `aws configure` or `aws sso login`

### Error: "VPC not found"
- Check if default VPC exists: `aws ec2 describe-vpcs --filters "Name=isDefault,Values=true"`
- Or specify a custom VPC in `terraform.tfvars`

### Error: "Insufficient permissions" or "UnauthorizedOperation"
- **Most common issue**: Missing EC2 permissions to create security groups
- See [IAM_PERMISSIONS.md](./IAM_PERMISSIONS.md) for complete setup guide
- Quick fix: Attach the `TerraformDeploymentPolicy` to your IAM user
- Verify permissions: `aws ec2 describe-security-groups --max-items 1`

### Error: "The security token included in the request is invalid"
- **AWS credentials are expired or invalid**
- See [FIX_CREDENTIALS.md](./FIX_CREDENTIALS.md) for detailed steps
- Quick fix: Run `aws configure` to reconfigure credentials
- Verify: `aws sts get-caller-identity`

### Error: "Bucket name already exists"
- S3 bucket names are globally unique
- Change the bucket name in `main.tf` or use a different name

## Next Steps After Deployment

1. **Update GitHub Secrets:**
   - `DATABASE_URL`: Use RDS endpoint from Terraform output
   - `CLOUDFRONT_DISTRIBUTION_ID`: From Terraform output

2. **Trigger GitHub Actions:**
   - Push to `main` branch, or
   - Manually trigger "Full Deployment to AWS" workflow

3. **Verify Deployment:**
   - Check App Runner service status
   - Test frontend URL (CloudFront domain)
   - Test backend API endpoint

## Cost Estimation

- **RDS db.t3.micro**: ~$15/month
- **ECR**: Minimal (storage + transfer)
- **S3**: ~$1-5/month (depending on traffic)
- **CloudFront**: ~$1-10/month (depending on traffic)
- **App Runner**: ~$25/month (1 vCPU, 2GB)

**Total**: ~$40-50/month

## Support

For issues or questions, refer to:
- [IAM Permissions Guide](./IAM_PERMISSIONS.md) - **Fix permission errors here!**
- [AWS Deployment Guide](../README.md)
- [GitHub Setup Guide](../../GITHUB_SETUP.md)
- [Main README](../../README.md)
