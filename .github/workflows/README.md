# GitHub Actions Workflows

This directory contains CI/CD workflows for the Nonprofit Learning Platform.

## Available Workflows

### 1. CI (`ci.yml`)
**Triggers:** Push/PR to `main` or `develop`

- Runs backend tests with PostgreSQL
- Runs frontend linting and build
- Validates code quality

### 2. Deploy Backend (`deploy-backend.yml`)
**Triggers:** Push to `main` (backend changes)

- Builds Docker image
- Pushes to Amazon ECR
- Deploys to AWS App Runner
- Runs database migrations

### 3. Deploy Frontend - S3 (`deploy-frontend.yml`)
**Triggers:** Push to `main` (frontend changes)

- Builds Next.js application
- Deploys to S3 bucket
- Invalidates CloudFront cache

**Note:** For better Next.js support, consider using the Amplify workflow instead.

### 4. Deploy Frontend - Amplify (`deploy-amplify.yml`)
**Triggers:** Push to `main` (frontend changes)

- Triggers AWS Amplify build
- Better Next.js SSR support
- Automatic deployments

### 5. Deploy Database (`deploy-database.yml`)
**Triggers:** Push to `main` (migration changes) or manual

- Runs Alembic migrations
- Updates database schema
- Safe for production use

### 6. Full Deployment (`full-deploy.yml`)
**Triggers:** Push to `main` or manual with options

- Orchestrates all deployments
- Can selectively deploy components
- Includes notification step

## Required GitHub Secrets

See [GITHUB_SETUP.md](../GITHUB_SETUP.md) for complete list.

Minimum required:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DATABASE_URL`
- `CLERK_SECRET_KEY`
- `CLERK_PUBLISHABLE_KEY`
- `CLERK_FRONTEND_API`
- `CORS_ORIGINS`
- `NEXT_PUBLIC_API_URL`

## Usage

### Automatic Deployment
Push to `main` branch → All relevant workflows run automatically

### Manual Deployment
1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Choose options (if available)
5. Click "Run workflow"

### Viewing Logs
1. Go to Actions tab
2. Click on workflow run
3. Click on job
4. Expand steps to see logs

## Troubleshooting

### Workflow fails immediately
- Check GitHub Secrets are configured
- Verify AWS credentials are valid
- Check workflow file syntax

### Build fails
- Check dependency files (requirements.txt, package.json)
- Review build logs for specific errors
- Verify environment variables

### Deployment fails
- Check AWS permissions
- Verify resource names match
- Review CloudWatch logs (for AWS resources)
