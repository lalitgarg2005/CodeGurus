# Deployment Notes

## Database Setup

**Yes, you need to create the database first!**

The backend requires a PostgreSQL database. You have two options:

### Option 1: Use Terraform (Recommended)
```bash
cd aws/terraform
# Edit terraform.tfvars with your database password
terraform init
terraform plan
terraform apply
```

After Terraform completes, get the RDS endpoint from outputs and add it to GitHub Secrets as:
```
DATABASE_URL=postgresql://username:password@rds-endpoint:5432/nonprofit_learning
```

### Option 2: Create RDS Manually
1. Go to AWS Console → RDS
2. Create PostgreSQL database (db.t3.micro recommended)
3. Note the endpoint
4. Add DATABASE_URL to GitHub Secrets

## ECR Repository

The workflow will automatically create the ECR repository if it doesn't exist.

If you don't see images in ECR:
1. Check GitHub Actions logs for errors
2. Verify IAM user has these permissions:
   - ecr:CreateRepository
   - ecr:GetAuthorizationToken
   - ecr:BatchCheckLayerAvailability
   - ecr:GetDownloadUrlForLayer
   - ecr:BatchGetImage
   - ecr:PutImage
   - ecr:InitiateLayerUpload
   - ecr:UploadLayerPart
   - ecr:CompleteLayerUpload

## Required GitHub Secrets

- `AWS_ACCESS_KEY_ID` ✅ (you have this)
- `AWS_SECRET_ACCESS_KEY` ✅ (you have this)
- `DATABASE_URL` ⚠️ (needed for backend to work, but deployment can proceed without it)
- `CLERK_SECRET_KEY`
- `CLERK_PUBLISHABLE_KEY`
- `CLERK_FRONTEND_API`
- `CORS_ORIGINS`
- `NEXT_PUBLIC_API_URL`

## Deployment Order

1. **First**: Create database (RDS) - Required for backend to function
2. **Then**: Deploy backend (will create ECR and push images)
3. **Finally**: Deploy frontend

The workflow will proceed even if database doesn't exist, but backend won't work until DATABASE_URL is set.
