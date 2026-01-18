# Deploy Backend to App Runner

## ❌ Issue: Backend Not Deployed

The `nonprofit-learning-backend` service doesn't exist in App Runner yet. You need to deploy it first.

## 🚀 Quick Deploy (Recommended)

### Option 1: Deploy via GitHub Actions (Easiest)

1. **Go to GitHub Actions:**
   - Your repository → **Actions** tab
   - Find **"Deploy Backend to AWS"** workflow
   - Click **Run workflow** → **Run workflow**

2. **Wait for deployment:**
   - The workflow will:
     - Build Docker image
     - Push to ECR
     - Create/update App Runner service
   - Takes ~10-15 minutes

3. **Check status:**
   - Watch the workflow run
   - Look for "✅ App Runner deployment completed"
   - If it fails, check the logs

4. **Verify:**
   - Go to: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
   - You should see `nonprofit-learning-backend`

### Option 2: Trigger by Pushing Code

If the workflow runs on push to `main`:

```bash
# Make a small change to trigger deployment
cd backend
echo "# Deployment trigger" >> README.md 2>/dev/null || touch .deploy-trigger
git add .
git commit -m "Trigger backend deployment"
git push origin main
```

## 📋 Prerequisites Check

Before deploying, make sure you have:

### 1. ECR Repository

Check if ECR repository exists:
```bash
aws ecr describe-repositories \
  --repository-names nonprofit-learning-backend \
  --region us-east-1
```

If it doesn't exist, the workflow will create it automatically.

### 2. Required GitHub Secrets

Make sure these secrets are set in GitHub:
- ✅ `AWS_ACCESS_KEY_ID`
- ✅ `AWS_SECRET_ACCESS_KEY`
- ✅ `DATABASE_URL` (optional but recommended)
- ✅ `CLERK_SECRET_KEY`
- ✅ `CLERK_PUBLISHABLE_KEY`
- ✅ `CLERK_FRONTEND_API`
- ✅ `CORS_ORIGINS` (should include your Amplify URL)

### 3. Docker Image in ECR

The workflow will build and push the image automatically, but you can check:
```bash
aws ecr list-images \
  --repository-name nonprofit-learning-backend \
  --region us-east-1
```

## 🔧 Manual Deployment (If GitHub Actions Fails)

If the GitHub Actions workflow fails, you can deploy manually:

### Step 1: Build and Push Docker Image

```bash
# Get ECR login
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

# Get ECR repository URI
ECR_URI=$(aws ecr describe-repositories \
  --repository-names nonprofit-learning-backend \
  --region us-east-1 \
  --query 'repositories[0].repositoryUri' \
  --output text)

# Build image
cd backend
docker build -t nonprofit-learning-backend:latest .

# Tag and push
docker tag nonprofit-learning-backend:latest $ECR_URI:latest
docker push $ECR_URI:latest
```

### Step 2: Create App Runner Service

```bash
# Get ECR repository URI
ECR_URI=$(aws ecr describe-repositories \
  --repository-names nonprofit-learning-backend \
  --region us-east-1 \
  --query 'repositories[0].repositoryUri' \
  --output text)

# Create App Runner service
aws apprunner create-service \
  --service-name nonprofit-learning-backend \
  --source-configuration "{
    \"ImageRepository\": {
      \"ImageIdentifier\": \"$ECR_URI:latest\",
      \"ImageRepositoryType\": \"ECR\",
      \"ImageConfiguration\": {
        \"Port\": \"8000\",
        \"RuntimeEnvironmentVariables\": {
          \"DATABASE_URL\": \"YOUR_DATABASE_URL\",
          \"CLERK_SECRET_KEY\": \"YOUR_CLERK_SECRET_KEY\",
          \"CLERK_PUBLISHABLE_KEY\": \"YOUR_CLERK_PUBLISHABLE_KEY\",
          \"CLERK_FRONTEND_API\": \"YOUR_CLERK_FRONTEND_API\",
          \"ENVIRONMENT\": \"production\",
          \"CORS_ORIGINS\": \"YOUR_CORS_ORIGINS\"
        }
      }
    },
    \"AutoDeploymentsEnabled\": true
  }" \
  --instance-configuration '{"Cpu": "1 vCPU", "Memory": "2 GB"}' \
  --region us-east-1
```

**Replace the placeholder values** with your actual secrets.

## ⏱️ After Deployment

1. **Wait 5-10 minutes** for the service to start
2. **Check service status:**
   - AWS Console → App Runner → Services
   - Status should be "Running"

3. **Get the service URL:**
   - Click on `nonprofit-learning-backend`
   - Copy the **Service URL**

4. **Test the service:**
   ```bash
   curl https://your-service-url.us-east-1.awsapprunner.com/health
   ```

5. **Update Amplify:**
   - Use this URL as `NEXT_PUBLIC_API_URL` in Amplify environment variables

## 🐛 Troubleshooting

### Workflow Fails?

1. **Check GitHub Actions logs:**
   - Go to Actions → Failed workflow → Check error messages

2. **Common errors:**
   - **ECR permission denied** → Check IAM permissions
   - **Image build failed** → Check Dockerfile and backend code
   - **App Runner creation failed** → Check App Runner is enabled
   - **Missing secrets** → Verify all GitHub secrets are set

### Service Created But Not Running?

1. **Check service logs:**
   - App Runner Console → Your service → Logs
   - Look for startup errors

2. **Common issues:**
   - **Database connection failed** → Check DATABASE_URL
   - **Port mismatch** → Should be port 8000
   - **Missing environment variables** → Check Runtime environment variables

### Service URL Not Working?

1. **Check service status:**
   - Should be "Running" (not "Create failed" or "Update failed")

2. **Test health endpoint:**
   ```bash
   curl https://your-service-url/health
   ```

3. **Check service logs** for errors

## ✅ Verification Checklist

- [ ] GitHub Actions workflow ran successfully
- [ ] ECR repository exists and has images
- [ ] App Runner service `nonprofit-learning-backend` exists
- [ ] Service status is "Running"
- [ ] Service URL is accessible (`/health` endpoint works)
- [ ] Got the service URL for Amplify configuration

## 📖 Next Steps

After backend is deployed:

1. **Get the App Runner URL** (from service details)
2. **Set it in Amplify** as `NEXT_PUBLIC_API_URL`
3. **Redeploy Amplify** to pick up the new backend URL
4. **Test your application**

See `SET_AMPLIFY_ENV_VARS.md` for setting Amplify variables.
