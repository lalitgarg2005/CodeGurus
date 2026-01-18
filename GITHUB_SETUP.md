# GitHub Repository Setup Guide

This guide explains how to set up your GitHub repository and configure GitHub Actions for AWS deployment.

## Initial Repository Setup

### 1. Initialize Git Repository

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Nonprofit Learning Platform"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/nonprofit-learning-platform.git

# Push to GitHub
git push -u origin main
```

### 2. Create GitHub Repository

1. Go to GitHub.com
2. Click "New repository"
3. Name: `nonprofit-learning-platform`
4. Description: "Production-grade nonprofit learning platform"
5. Visibility: Private (recommended) or Public
6. **Don't** initialize with README (we already have one)
7. Click "Create repository"

## GitHub Secrets Configuration

### Required Secrets

Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

#### AWS Credentials
- `AWS_ACCESS_KEY_ID` - Your AWS IAM user access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS IAM user secret key

#### Database
- `DATABASE_URL` - RDS PostgreSQL connection string
  ```
  postgresql://username:password@your-rds-endpoint.rds.amazonaws.com:5432/nonprofit_learning
  ```

#### Clerk Authentication
- `CLERK_SECRET_KEY` - Your Clerk secret key (starts with `sk_live_` or `sk_test_`)
- `CLERK_PUBLISHABLE_KEY` - Your Clerk publishable key (starts with `pk_live_` or `pk_test_`)
- `CLERK_FRONTEND_API` - Your Clerk frontend API URL
  ```
  https://your-app.clerk.accounts.dev
  ```

#### Application Configuration
- `CORS_ORIGINS` - Allowed CORS origins (comma-separated)
  ```
  https://your-frontend-domain.com,https://www.your-frontend-domain.com
  ```
- `NEXT_PUBLIC_API_URL` - Backend API URL for frontend
  ```
  https://your-backend-api.apprunner.aws-region.amazonaws.com
  ```

#### Optional (for CloudFront)
- `CLOUDFRONT_DISTRIBUTION_ID` - CloudFront distribution ID (if using S3+CloudFront)
- `AMPLIFY_APP_ID` - AWS Amplify app ID (if using Amplify)

## AWS IAM User Setup

Create an IAM user with the following permissions:

### Required Policies

1. **AmazonEC2ContainerRegistryFullAccess** - For ECR
2. **AmazonAppRunnerFullAccess** - For App Runner
3. **AmazonS3FullAccess** - For S3 (or restrict to specific bucket)
4. **CloudFrontFullAccess** - For CloudFront (if using)
5. **AmazonRDSFullAccess** - For RDS (or restrict to specific instance)

### Create IAM User

```bash
# Create IAM user
aws iam create-user --user-name github-actions-deploy

# Attach policies
aws iam attach-user-policy \
  --user-name github-actions-deploy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-user-policy \
  --user-name github-actions-deploy \
  --policy-arn arn:aws:iam::aws:policy/AmazonAppRunnerFullAccess

# Create access key
aws iam create-access-key --user-name github-actions-deploy
```

Save the Access Key ID and Secret Access Key - add them to GitHub Secrets.

## Workflow Files

The following GitHub Actions workflows are included:

1. **`.github/workflows/ci.yml`** - Continuous Integration
   - Runs on push/PR
   - Tests backend and frontend
   - Runs linting

2. **`.github/workflows/deploy-backend.yml`** - Backend Deployment
   - Deploys to AWS App Runner
   - Builds Docker image
   - Pushes to ECR
   - Updates App Runner service

3. **`.github/workflows/deploy-frontend.yml`** - Frontend Deployment (S3)
   - Builds Next.js app
   - Deploys to S3
   - Invalidates CloudFront cache

4. **`.github/workflows/deploy-amplify.yml`** - Frontend Deployment (Amplify)
   - Alternative: Deploys to AWS Amplify
   - Triggers Amplify build

5. **`.github/workflows/deploy-database.yml`** - Database Migrations
   - Runs Alembic migrations
   - Can be triggered manually

6. **`.github/workflows/full-deploy.yml`** - Full Deployment
   - Orchestrates all deployments
   - Can be triggered manually with options

## Deployment Workflow

### Automatic Deployment

When you push to `main` branch:
1. CI tests run
2. Backend deploys to App Runner
3. Frontend deploys to S3/Amplify
4. Database migrations run

### Manual Deployment

1. Go to Actions tab
2. Select "Full Deployment to AWS"
3. Click "Run workflow"
4. Choose what to deploy
5. Click "Run workflow"

## Branch Protection (Recommended)

Set up branch protection for `main`:

1. Go to Settings → Branches
2. Add rule for `main`
3. Enable:
   - Require pull request reviews
   - Require status checks to pass
   - Require branches to be up to date

## Monitoring Deployments

- View deployment status: Actions tab
- View logs: Click on workflow run
- Monitor AWS: CloudWatch, App Runner console

## Troubleshooting

### Workflow fails with "Access Denied"

- Check IAM user permissions
- Verify AWS credentials in GitHub Secrets
- Check resource names match

### Build fails

- Check logs in Actions tab
- Verify all dependencies are in requirements.txt/package.json
- Check for syntax errors

### Deployment succeeds but app doesn't work

- Check environment variables in App Runner
- Verify DATABASE_URL is correct
- Check CORS_ORIGINS includes your frontend domain
- Review CloudWatch logs

## Next Steps

1. Set up AWS infrastructure (RDS, ECR, S3, CloudFront)
2. Configure GitHub Secrets
3. Push code to GitHub
4. Monitor first deployment
5. Set up custom domain (optional)
6. Configure SSL certificates
