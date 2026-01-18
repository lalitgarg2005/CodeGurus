# Step-by-Step: Set Amplify Environment Variables

## 🎯 Goal

Set these 3 environment variables in Amplify:
1. `NEXT_PUBLIC_API_URL` - Your App Runner backend URL
2. `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` - Your Clerk publishable key
3. `NEXT_PUBLIC_CLERK_FRONTEND_API` - Your Clerk frontend API URL

## 📋 Step 1: Get Your App Runner URL

### Option A: Using AWS CLI
```bash
aws apprunner list-services --region us-east-1 \
  --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
  --output text
```

### Option B: Using AWS Console
1. Go to: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
2. Click on `nonprofit-learning-backend`
3. Copy the **Service URL** (format: `https://xxxxx.us-east-1.awsapprunner.com`)

**Save this URL** - you'll need it in Step 3!

## 📋 Step 2: Get Your Clerk Values

### Get Clerk Publishable Key
1. Go to: https://dashboard.clerk.com
2. Select your application
3. Go to: **API Keys** (left sidebar)
4. Copy the **Publishable key** (starts with `pk_test_` or `pk_live_`)

### Get Clerk Frontend API URL
1. Still in Clerk Dashboard
2. Go to: **Configure** (left sidebar) → **Frontend API**
3. Copy the URL (format: `https://your-app-name.clerk.accounts.dev`)
   - Or check the **Domains** section for your frontend API URL

**Save both values** - you'll need them in Step 3!

## 📋 Step 3: Set Variables in Amplify

### 3.1 Open Amplify Console

1. Go to: https://console.aws.amazon.com/amplify/home?region=us-east-1
2. Click on your app (e.g., `nonprofit-learning-frontend`)

### 3.2 Navigate to Environment Variables

1. In the left sidebar, click **App settings**
2. Click **Environment variables**

### 3.3 Add/Update Variable 1: NEXT_PUBLIC_API_URL

1. Click **Add variable** (or **Edit** if it already exists)
2. **Key:** `NEXT_PUBLIC_API_URL`
3. **Value:** Paste your App Runner URL from Step 1
   - Example: `https://abc123xyz.us-east-1.awsapprunner.com`
4. Click **Save**

### 3.4 Add/Update Variable 2: NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY

1. Click **Add variable** (or **Edit** if it already exists)
2. **Key:** `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
3. **Value:** Paste your Clerk publishable key from Step 2
   - Example: `pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
4. Click **Save**

### 3.5 Add/Update Variable 3: NEXT_PUBLIC_CLERK_FRONTEND_API

1. Click **Add variable** (or **Edit** if it already exists)
2. **Key:** `NEXT_PUBLIC_CLERK_FRONTEND_API`
3. **Value:** Paste your Clerk frontend API URL from Step 2
   - Example: `https://your-app-name.clerk.accounts.dev`
4. Click **Save**

### 3.6 Verify All Variables

You should now see all 3 variables listed:
- ✅ `NEXT_PUBLIC_API_URL`
- ✅ `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
- ✅ `NEXT_PUBLIC_CLERK_FRONTEND_API`

## 📋 Step 4: Redeploy Amplify

**Important:** After adding/updating environment variables, you MUST redeploy!

1. In Amplify Console, go to your branch (usually **main**)
2. Click **Actions** (top menu)
3. Click **Redeploy this version**
4. Wait for the build to complete (usually 5-10 minutes)

## ✅ Step 5: Verify

1. **Check build status:**
   - Go to: Build history
   - Make sure the latest build succeeded

2. **Test your Amplify URL:**
   - Open your Amplify URL in a browser
   - Press F12 to open Developer Tools
   - Check Console tab for errors
   - The page should load without errors

3. **Test backend connection:**
   - Try signing in/up
   - If authentication works, the backend connection is good!

## 🐛 Troubleshooting

### Build Failed?
- Check build logs in Amplify Console
- Verify all 3 variables are set correctly
- Make sure there are no typos in the URLs

### Page Still Not Loading?
- Check browser console (F12) for errors
- Verify `NEXT_PUBLIC_API_URL` is correct (test it: `curl https://your-app-runner-url/health`)
- Make sure you redeployed after adding variables

### Authentication Not Working?
- Verify Clerk keys are correct
- Check that your Amplify URL is added to Clerk's allowed origins:
  - Clerk Dashboard → Configure → Allowed origins
  - Add: `https://main.xxxxx.amplifyapp.com`

## 📸 Visual Guide

### Finding Environment Variables in Amplify:
```
Amplify Console
  └── Your App
      └── App settings (left sidebar)
          └── Environment variables
              └── Add variable / Edit
```

### What It Should Look Like:
```
Environment Variables:
┌─────────────────────────────────────┬──────────────────────────────────────┐
│ Key                                  │ Value                                 │
├─────────────────────────────────────┼──────────────────────────────────────┤
│ NEXT_PUBLIC_API_URL                 │ https://xxx.us-east-1.awsapprunner...│
│ NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY   │ pk_test_xxxxxxxxxxxxxxxxxxxxx        │
│ NEXT_PUBLIC_CLERK_FRONTEND_API      │ https://your-app.clerk.accounts.dev   │
└─────────────────────────────────────┴──────────────────────────────────────┘
```

## 💡 Quick Reference

**Amplify Console:** https://console.aws.amazon.com/amplify/home?region=us-east-1

**App Runner Console:** https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services

**Clerk Dashboard:** https://dashboard.clerk.com
