# Fix App Runner Authentication Error

## ❌ Error
```
InvalidRequestException: Authentication configuration is invalid.
```

## 🔍 Problem

App Runner needs an IAM role to access ECR (Elastic Container Registry) to pull Docker images. The authentication configuration is missing.

## ✅ Solution

### Step 1: Create IAM Role for App Runner

Run this script to create the required IAM role:

```bash
./create-apprunner-role.sh
```

This will:
- Create an IAM role named `AppRunnerECRAccessRole`
- Give it permissions to read from ECR
- Output the role ARN

### Step 2: Add Role ARN to GitHub Secrets

1. **Get the role ARN** from the script output (or run):
   ```bash
   aws iam get-role --role-name AppRunnerECRAccessRole --query 'Role.Arn' --output text
   ```

2. **Add to GitHub Secrets:**
   - Go to: Your repository → Settings → Secrets and variables → Actions
   - Click **New repository secret**
   - Name: `APP_RUNNER_ACCESS_ROLE_ARN`
   - Value: The role ARN (format: `arn:aws:iam::ACCOUNT_ID:role/AppRunnerECRAccessRole`)
   - Click **Add secret**

### Step 3: Re-run Deployment

After adding the secret, re-run the deployment workflow:
- Go to Actions → Deploy Backend to AWS → Run workflow

## 🔧 Manual Role Creation (If Script Fails)

If the script doesn't work, create the role manually:

### 1. Create Trust Policy

Create a file `trust-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "build.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 2. Create Role

```bash
aws iam create-role \
  --role-name AppRunnerECRAccessRole \
  --assume-role-policy-document file://trust-policy.json \
  --description "Allows App Runner to access ECR repositories"
```

### 3. Attach ECR Read Policy

```bash
aws iam attach-role-policy \
  --role-name AppRunnerECRAccessRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

### 4. Get Role ARN

```bash
aws iam get-role --role-name AppRunnerECRAccessRole --query 'Role.Arn' --output text
```

### 5. Add to GitHub Secrets

Add `APP_RUNNER_ACCESS_ROLE_ARN` with the role ARN value.

## ✅ Verification

After creating the role and adding the secret:

1. **Verify role exists:**
   ```bash
   aws iam get-role --role-name AppRunnerECRAccessRole
   ```

2. **Verify secret is set:**
   - Check GitHub Secrets has `APP_RUNNER_ACCESS_ROLE_ARN`

3. **Re-run deployment:**
   - The workflow should now succeed

## 📋 What Changed

The workflow has been updated to:
- Look for `APP_RUNNER_ACCESS_ROLE_ARN` in GitHub Secrets
- If not found, try to find existing `AppRunnerECRAccessRole`
- Include `AuthenticationConfiguration` in App Runner service creation

## 🐛 Still Having Issues?

1. **Check IAM permissions:**
   - Your IAM user needs `iam:CreateRole` and `iam:AttachRolePolicy` permissions
   - Or ask an admin to create the role

2. **Check role ARN format:**
   - Should be: `arn:aws:iam::ACCOUNT_ID:role/AppRunnerECRAccessRole`
   - Replace `ACCOUNT_ID` with your AWS account ID

3. **Verify ECR permissions:**
   - The role needs `AmazonEC2ContainerRegistryReadOnly` policy
   - Check: `aws iam list-attached-role-policies --role-name AppRunnerECRAccessRole`
