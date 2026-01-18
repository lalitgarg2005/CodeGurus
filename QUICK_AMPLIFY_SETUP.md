# Quick Setup: Amplify Environment Variables

## 🎯 Your Amplify App
- **App ID:** `d1nedh505k7e12`
- **URL:** `https://main.d1nedh505k7e12.amplifyapp.com`
- **Console:** https://console.aws.amazon.com/amplify/home?region=us-east-1#/d1nedh505k7e12

## 📋 Quick Steps

### 1. Get Your App Runner URL

Run this command:
```bash
aws apprunner list-services --region us-east-1 \
  --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
  --output text
```

**Or find it in AWS Console:**
- https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
- Click on `nonprofit-learning-backend`
- Copy the **Service URL**

### 2. Get Your Clerk Values

**Clerk Dashboard:** https://dashboard.clerk.com

- **Publishable Key:** API Keys → Copy publishable key (starts with `pk_test_` or `pk_live_`)
- **Frontend API:** Configure → Frontend API → Copy URL (format: `https://your-app.clerk.accounts.dev`)

### 3. Set in Amplify

**Direct Link:** https://console.aws.amazon.com/amplify/home?region=us-east-1#/d1nedh505k7e12/settings/environment-variables

1. Click **Add variable** for each:

   **Variable 1:**
   - Key: `NEXT_PUBLIC_API_URL`
   - Value: Your App Runner URL (from step 1)

   **Variable 2:**
   - Key: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
   - Value: Your Clerk publishable key (from step 2)

   **Variable 3:**
   - Key: `NEXT_PUBLIC_CLERK_FRONTEND_API`
   - Value: Your Clerk frontend API URL (from step 2)

2. Click **Save** for each variable

### 4. Redeploy

1. Go to: https://console.aws.amazon.com/amplify/home?region=us-east-1#/d1nedh505k7e12/main
2. Click **Actions** → **Redeploy this version**
3. Wait for build to complete (~5-10 minutes)

### 5. Test

Open: https://main.d1nedh505k7e12.amplifyapp.com

## ✅ Checklist

- [ ] Got App Runner URL
- [ ] Got Clerk publishable key
- [ ] Got Clerk frontend API URL
- [ ] Set `NEXT_PUBLIC_API_URL` in Amplify
- [ ] Set `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` in Amplify
- [ ] Set `NEXT_PUBLIC_CLERK_FRONTEND_API` in Amplify
- [ ] Redeployed Amplify
- [ ] Tested the URL

## 📖 Detailed Guide

For more detailed instructions, see: `SET_AMPLIFY_ENV_VARS.md`
