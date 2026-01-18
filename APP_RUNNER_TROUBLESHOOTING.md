# App Runner Not Loading - Troubleshooting Guide

## ❌ Error: SubscriptionRequiredException

If you see this error:
```
SubscriptionRequiredException: The AWS Access Key Id needs a subscription for the service
```

**This means:** App Runner is not enabled/subscribed in your AWS account.

## 🔍 Is App Runner Available?

App Runner **does not have a free tier**, but it's a paid service that needs to be enabled. However, the subscription is usually automatic when you first use it.

### Check 1: AWS Console

1. **Go to App Runner Console:**
   - https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services

2. **If you see an error or "Service unavailable":**
   - App Runner might not be available in your region
   - Or your account needs App Runner enabled

3. **If the page loads:**
   - Check if your service `nonprofit-learning-backend` exists
   - Check its status (Running, Failed, etc.)

### Check 2: Service Status

If the service exists, check its status:

**Possible statuses:**
- **Running** ✅ - Service is active and should be accessible
- **Operation in progress** ⏳ - Service is starting/updating (wait 5-10 minutes)
- **Create failed** ❌ - Service creation failed (check logs)
- **Update failed** ❌ - Service update failed (check logs)
- **Paused** ⏸️ - Service is paused (resume it)

## 🔧 Solutions

### Solution 1: Enable App Runner (If Not Available)

1. **Try accessing App Runner Console:**
   - https://console.aws.amazon.com/apprunner/home?region=us-east-1

2. **If you see "Service unavailable":**
   - App Runner might not be available in your account
   - Contact AWS Support to enable App Runner
   - Or use an alternative (see Solution 2)

### Solution 2: Use Alternative Backend Hosting

If App Runner isn't available, consider these alternatives:

#### Option A: AWS ECS Fargate (Free Tier Eligible)
- ECS Fargate has a free tier (750 hours/month for 12 months)
- More complex setup but more flexible

#### Option B: AWS Lambda + API Gateway
- Serverless, pay-per-request
- Good for low traffic
- Free tier: 1M requests/month

#### Option C: EC2 (Free Tier Eligible)
- t2.micro instance is free for 12 months
- Full control but you manage the server

#### Option D: Railway, Render, or Fly.io
- Third-party platforms with free tiers
- Easier setup, good for development

### Solution 3: Check Service Deployment

If App Runner is enabled, check if the service was deployed:

1. **Check GitHub Actions logs:**
   - Go to your repository → Actions
   - Check the "Deploy Backend" workflow
   - Look for errors during App Runner creation

2. **Check if service exists:**
   - AWS Console → App Runner → Services
   - Look for `nonprofit-learning-backend`

3. **If service doesn't exist:**
   - The deployment might have failed
   - Check GitHub Actions logs for errors
   - Re-run the deployment workflow

### Solution 4: Check Service Health

If the service exists but URL doesn't load:

1. **Check service status:**
   - App Runner Console → Your service
   - Check "Status" and "Health"

2. **Check logs:**
   - App Runner Console → Your service → Logs
   - Look for errors or startup issues

3. **Common issues:**
   - **Missing environment variables** - Check Runtime environment variables
   - **Database connection failed** - Verify DATABASE_URL
   - **Port mismatch** - Should be port 8000
   - **Health check failing** - Verify `/health` endpoint works

## 📋 Quick Diagnostic Steps

### Step 1: Check App Runner Console

```bash
# Open in browser:
https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
```

**What to look for:**
- Does the page load? (If no → App Runner not enabled)
- Is there a service named `nonprofit-learning-backend`?
- What's the service status?

### Step 2: Check GitHub Actions

1. Go to: Your repository → Actions
2. Find the latest "Deploy Backend" run
3. Check for errors:
   - "SubscriptionRequiredException" → App Runner not enabled
   - "Service creation failed" → Check error details
   - "Image not found" → ECR image not pushed

### Step 3: Check ECR (Container Registry)

The backend needs a Docker image in ECR:

```bash
# Check if image exists:
aws ecr describe-images \
  --repository-name nonprofit-learning-backend \
  --region us-east-1
```

If no images exist, the backend deployment failed.

## 💰 Cost Information

**App Runner Pricing:**
- **No free tier**
- ~$0.007 per vCPU-hour
- ~$0.0008 per GB-hour
- Minimum: 1 vCPU, 2 GB = ~$0.014/hour = ~$10/month (if running 24/7)

**For development/testing:**
- Consider stopping the service when not in use
- Or use ECS Fargate (has free tier) or Lambda (pay-per-request)

## 🚀 Quick Fix: Deploy to Alternative

If App Runner isn't working, you can quickly deploy to:

### Railway (Easiest, Free Tier)
1. Sign up: https://railway.app
2. Connect GitHub repository
3. Deploy backend folder
4. Set environment variables
5. Get URL → Use as `NEXT_PUBLIC_API_URL`

### Render (Free Tier)
1. Sign up: https://render.com
2. Create Web Service
3. Connect GitHub repository
4. Set build command: `cd backend && pip install -r requirements.txt`
5. Set start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

## ✅ Verification Checklist

- [ ] App Runner Console is accessible
- [ ] Service `nonprofit-learning-backend` exists
- [ ] Service status is "Running"
- [ ] Service URL is accessible (try `/health` endpoint)
- [ ] Environment variables are set correctly
- [ ] Docker image exists in ECR
- [ ] GitHub Actions deployment succeeded

## 🆘 Still Not Working?

1. **Check AWS Support:**
   - Contact AWS Support to enable App Runner
   - Or ask about account limitations

2. **Use Alternative:**
   - Deploy to Railway, Render, or Fly.io
   - Update `NEXT_PUBLIC_API_URL` in Amplify

3. **Check Service Logs:**
   - App Runner Console → Your service → Logs
   - Look for startup errors or crashes
