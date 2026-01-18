# AWS Deployment Guide

This guide explains how to deploy the Nonprofit Learning Platform to AWS.

## Architecture

- **Backend**: AWS App Runner (or ECS Fargate)
- **Frontend**: AWS S3 + CloudFront (or AWS Amplify)
- **Database**: AWS RDS PostgreSQL
- **Container Registry**: Amazon ECR

## Prerequisites

1. AWS Account with appropriate permissions
2. AWS CLI configured
3. Terraform (optional, for infrastructure as code)
4. GitHub repository with secrets configured

## GitHub Secrets Setup

Configure these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

### Required Secrets

```
AWS_ACCESS_KEY_ID          # AWS IAM user access key
AWS_SECRET_ACCESS_KEY     # AWS IAM user secret key
DATABASE_URL              # RDS PostgreSQL connection string
CLERK_SECRET_KEY          # Clerk secret key
CLERK_PUBLISHABLE_KEY     # Clerk publishable key
CLERK_FRONTEND_API        # Clerk frontend API URL
CORS_ORIGINS              # Allowed CORS origins (comma-separated)
                          # Example: https://your-frontend-domain.com,https://www.your-frontend-domain.com
                          # Get from: CloudFront distribution URL or S3 website endpoint after frontend deployment
NEXT_PUBLIC_API_URL       # Backend API URL for frontend
                          # Example: https://your-app-runner-service.us-east-1.awsapprunner.com
                          # Get from: AWS App Runner service URL after backend deployment
CLOUDFRONT_DISTRIBUTION_ID # CloudFront distribution ID (optional)
AMPLIFY_APP_ID            # AWS Amplify app ID (if using Amplify)
```

### How to Get These Values

#### CORS_ORIGINS
This is the URL(s) where your frontend application is deployed. The backend will only accept requests from these origins.

**Where to find it:**
- **If using CloudFront**: After creating your CloudFront distribution, use the CloudFront domain name (e.g., `https://d1234567890.cloudfront.net`)
- **If using S3 website**: Use the S3 website endpoint (e.g., `http://your-bucket-name.s3-website-us-east-1.amazonaws.com`)
- **If using AWS Amplify**: Use the Amplify app URL (e.g., `https://main.xxxxx.amplifyapp.com`)
- **For local development**: Include `http://localhost:3000`

**Format**: Comma-separated list of URLs (no trailing slashes)
- Example: `https://your-frontend-domain.com,https://www.your-frontend-domain.com`
- Example with localhost: `https://your-frontend-domain.com,http://localhost:3000`

#### NEXT_PUBLIC_API_URL
This is the public URL of your backend API service. The frontend uses this to make API calls.

**Where to find it:**
- **After deploying to App Runner**: 
  1. Go to AWS Console → App Runner → Your service
  2. Copy the "Service URL" (e.g., `https://xxxxx.us-east-1.awsapprunner.com`)
  3. This is your `NEXT_PUBLIC_API_URL`
- **For local development**: `http://localhost:8000`

**Note**: Make sure to include the protocol (`https://` or `http://`) but no trailing slash.

## Deployment Steps

### 1. Set Up AWS Infrastructure

#### Option A: Using Terraform (Recommended)

```bash
cd aws/terraform

# Initialize Terraform
terraform init

# Create terraform.tfvars
cat > terraform.tfvars << EOF
aws_region = "us-east-1"
db_username = "postgres"
db_password = "your-secure-password"
subnet_ids = ["subnet-xxx", "subnet-yyy"]
vpc_id = "vpc-xxx"
environment = "production"
EOF

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

#### Option B: Manual Setup via AWS Console

1. **Create RDS PostgreSQL Instance:**
   - Engine: PostgreSQL 14
   - Instance class: db.t3.micro (or larger)
   - Storage: 20GB
   - Master username: postgres
   - Master password: (set secure password)
   - VPC: Your VPC
   - Security group: Allow port 5432 from App Runner

2. **Create ECR Repository:**
   ```bash
   aws ecr create-repository --repository-name nonprofit-learning-backend --region us-east-1
   ```

3. **Create S3 Bucket:**
   ```bash
   aws s3 mb s3://nonprofit-learning-frontend --region us-east-1
   aws s3 website s3://nonprofit-learning-frontend --index-document index.html
   ```

4. **Create CloudFront Distribution:**
   - Origin: S3 bucket
   - Default root object: index.html
   - Viewer protocol: Redirect HTTP to HTTPS

### 2. Configure GitHub Secrets

Add all required secrets in GitHub repository settings.

### 3. Deploy Backend

The backend will automatically deploy when you push to `main` branch:

```bash
git add .
git commit -m "Deploy backend"
git push origin main
```

Or trigger manually:
- Go to Actions → Deploy Backend to AWS → Run workflow

### 4. Deploy Frontend

The frontend will automatically deploy when you push to `main` branch:

```bash
git add frontend/
git commit -m "Deploy frontend"
git push origin main
```

### 5. Run Database Migrations

Migrations run automatically on backend deployment, or manually:

```bash
# Via GitHub Actions
# Go to Actions → Deploy Database Migrations → Run workflow

# Or manually
cd backend
export DATABASE_URL="postgresql://user:password@rds-endpoint:5432/nonprofit_learning"
alembic upgrade head
```

## Manual Deployment (Alternative)

### Backend to App Runner

```bash
# 1. Build and push to ECR
cd backend
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URI
docker build -t nonprofit-learning-backend .
docker tag nonprofit-learning-backend:latest YOUR_ECR_URI:latest
docker push YOUR_ECR_URI:latest

# 2. Create/update App Runner service
aws apprunner create-service --cli-input-json file://aws/apprunner-config.json
```

### Frontend to S3

```bash
# 1. Build frontend
cd frontend
npm install
npm run build

# 2. Deploy to S3
aws s3 sync .next/standalone/. s3://nonprofit-learning-frontend/ --delete
aws s3 sync .next/static s3://nonprofit-learning-frontend/_next/static --delete
aws s3 sync public s3://nonprofit-learning-frontend/public --delete

# 3. Invalidate CloudFront
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

## Cost Estimation

- **RDS db.t3.micro**: ~$15/month
- **App Runner (1 vCPU, 2GB)**: ~$25/month
- **S3 + CloudFront**: ~$5-10/month
- **ECR**: Minimal (storage + transfer)
- **Total**: ~$45-50/month

## Monitoring

- **CloudWatch Logs**: App Runner logs automatically
- **RDS Monitoring**: CloudWatch metrics
- **Application Health**: `/health` and `/api/v1/health/db` endpoints

## Troubleshooting

### Backend deployment fails

1. Check ECR repository exists
2. Verify IAM permissions for App Runner
3. Check environment variables in App Runner service
4. Review CloudWatch logs

### Frontend deployment fails

1. Verify S3 bucket exists and is accessible
2. Check build process completes successfully
3. Verify CloudFront distribution is configured
4. Check CORS settings

### Database connection issues

1. Verify RDS security group allows App Runner
2. Check DATABASE_URL format
3. Verify RDS is in same VPC or accessible
4. Check RDS endpoint is correct

## Security Best Practices

1. **Use AWS Secrets Manager** for sensitive data
2. **Enable RDS encryption** at rest
3. **Use VPC** for database isolation
4. **Enable CloudFront SSL/TLS**
5. **Rotate credentials** regularly
6. **Use IAM roles** instead of access keys when possible

## Scaling

- **App Runner**: Auto-scales based on traffic
- **RDS**: Upgrade instance class for more capacity
- **CloudFront**: Handles global traffic automatically

## Backup Strategy

- **RDS Automated Backups**: Enabled by default (7 days retention)
- **Manual Snapshots**: Create before major changes
- **S3 Versioning**: Enable for frontend assets
