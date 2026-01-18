# Deployment Troubleshooting Guide

## Common Issues and Solutions

### 1. AWS Credentials Invalid

**Error:**
```
Error: The security token included in the request is invalid
```

**Solution:**
- See [FIX_CREDENTIALS.md](./aws/terraform/FIX_CREDENTIALS.md) for detailed steps
- Quick fix: Run `aws configure` and enter your credentials
- For GitHub Actions: Update `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub Secrets

---

### 2. IAM Permissions Error

**Error:**
```
An error occurred (UnauthorizedOperation) when calling the CreateSecurityGroup operation
```

**Solution:**
- See [IAM_PERMISSIONS.md](./aws/terraform/IAM_PERMISSIONS.md) for complete setup
- Attach the `TerraformDeploymentPolicy` to your IAM user
- Verify permissions: `./aws/terraform/check-permissions.sh`

---

### 3. GitHub Actions Jobs Not Running

**Issue:** Jobs like "Deploy Backend" or "Run Database Migrations" are skipped

**Possible Causes:**

#### A. Workflow Triggered Manually with Options Set to False
- When manually triggering "Full Deployment to AWS", check the input options
- Ensure `deploy_backend` and `run_migrations` are set to `true`

#### B. Workflow Conditions
- Fixed in latest version - jobs now run on `push` events automatically
- For manual triggers, ensure inputs are set correctly

#### C. Missing GitHub Secrets
- Check that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set
- Verify secrets are not expired

**Solution:**
1. Check workflow run logs in GitHub Actions
2. Look for "Skipped" jobs and their conditions
3. Re-run the workflow with correct inputs
4. Verify GitHub Secrets are set

---

### 4. Terraform Plan/Apply Fails

#### Error: "VPC not found"
```bash
# Check if default VPC exists
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true"

# Or specify VPC in terraform.tfvars
vpc_id = "vpc-xxxxxxxxx"
```

#### Error: "Bucket name already exists"
- S3 bucket names are globally unique
- Change bucket name in `main.tf` or use existing bucket

#### Error: "ExpiredToken"
- AWS credentials expired
- Run `aws configure` or `aws sso login`

---

### 5. Database Connection Issues

**Error:** Cannot connect to RDS database

**Check:**
1. **RDS exists**: `aws rds describe-db-instances`
2. **Security group**: Allows traffic from App Runner
3. **DATABASE_URL format**: 
   ```
   postgresql://username:password@endpoint:5432/dbname
   ```
4. **Database is available**: Status should be "available" not "creating"

**Solution:**
- Verify RDS endpoint in AWS Console
- Check security group rules
- Test connection: `psql $DATABASE_URL`

---

### 6. App Runner Deployment Fails

**Error:** Service creation/update fails

**Check:**
1. **ECR repository exists**: `aws ecr describe-repositories`
2. **Docker image exists**: `aws ecr list-images --repository-name nonprofit-learning-backend`
3. **IAM permissions**: App Runner needs permissions to pull from ECR
4. **Service already exists**: Check App Runner console

**Solution:**
- Create ECR repository first: `aws ecr create-repository --repository-name nonprofit-learning-backend`
- Build and push image manually if needed
- Check App Runner service logs in AWS Console

---

### 7. Frontend Not Loading

**Check:**
1. **S3 bucket has files**: `aws s3 ls s3://nonprofit-learning-frontend/`
2. **CloudFront distribution**: Status should be "Deployed"
3. **Bucket policy**: Allows public read access
4. **Build output**: Check if `frontend/out/` directory exists after build

**Solution:**
- Rebuild frontend: `cd frontend && npm run build`
- Redeploy to S3: `aws s3 sync out/ s3://nonprofit-learning-frontend/ --delete`
- Invalidate CloudFront cache

---

### 8. Database Migrations Fail

**Error:** Alembic migrations fail in GitHub Actions

**Check:**
1. **DATABASE_URL is set**: Check GitHub Secrets
2. **Database exists**: RDS instance must be created first
3. **Connection works**: Test from local machine
4. **Migrations are up to date**: Check `backend/alembic/versions/`

**Solution:**
- Create RDS database first (via Terraform or Console)
- Add `DATABASE_URL` to GitHub Secrets
- Run migrations manually: `cd backend && alembic upgrade head`

---

## Quick Diagnostic Commands

### Check AWS Configuration
```bash
# Verify credentials
aws sts get-caller-identity

# Check permissions
cd aws/terraform
./check-permissions.sh
```

### Check Terraform State
```bash
cd aws/terraform
terraform plan
terraform validate
```

### Check GitHub Actions
1. Go to repository → Actions
2. Click on failed workflow run
3. Check job logs for specific errors
4. Verify secrets are set: Settings → Secrets and variables → Actions

### Check AWS Resources
```bash
# List RDS instances
aws rds describe-db-instances

# List ECR repositories
aws ecr describe-repositories

# List App Runner services
aws apprunner list-services

# List S3 buckets
aws s3 ls

# List CloudFront distributions
aws cloudfront list-distributions
```

---

## Step-by-Step Recovery

If deployment is completely broken:

1. **Fix AWS Credentials**
   ```bash
   aws configure
   ```

2. **Verify Permissions**
   ```bash
   cd aws/terraform
   ./check-permissions.sh
   ```

3. **Create Infrastructure (if missing)**
   ```bash
   cd aws/terraform
   terraform plan
   terraform apply
   ```

4. **Update GitHub Secrets**
   - Go to repository → Settings → Secrets
   - Update `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
   - Add `DATABASE_URL` if missing

5. **Re-run GitHub Actions**
   - Go to Actions → "Full Deployment to AWS"
   - Click "Run workflow"
   - Ensure all options are set to `true`

---

## Getting Help

1. **Check logs**: Always check logs first (Terraform, GitHub Actions, CloudWatch)
2. **Verify prerequisites**: Ensure all prerequisites are met
3. **Test locally**: Try commands locally before running in CI/CD
4. **Check documentation**: Refer to specific guides:
   - [IAM_PERMISSIONS.md](./aws/terraform/IAM_PERMISSIONS.md)
   - [FIX_CREDENTIALS.md](./aws/terraform/FIX_CREDENTIALS.md)
   - [README.md](./aws/terraform/README.md)

---

## Prevention Tips

1. **Rotate credentials regularly** but update both local and GitHub Secrets
2. **Test Terraform changes** with `terraform plan` before applying
3. **Monitor GitHub Actions** for early detection of issues
4. **Keep documentation updated** when making infrastructure changes
5. **Use separate IAM users** for different environments (dev/prod)
