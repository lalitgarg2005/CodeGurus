# Fix Amplify Environment Variables

## ❌ Current Issue

Your Amplify environment variables are incorrect:

- `NEXT_PUBLIC_API_URL` = `https://your-app.clerk.accounts.dev` ❌ **WRONG!**
- `NEXT_PUBLIC_CLERK_FRONTEND_API` = `https://your-app.clerk.accounts.dev` ⚠️ (might be correct, but verify)

## ✅ Correct Values

### 1. NEXT_PUBLIC_API_URL

**Current (WRONG):** `https://your-app.clerk.accounts.dev`

**Should be:** Your **App Runner backend URL**

**How to find it:**
```bash
# Run this command:
aws apprunner list-services --region us-east-1 \
  --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
  --output text
```

**Format:** `https://xxxxx.us-east-1.awsapprunner.com`

**Or find it in AWS Console:**
1. Go to: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
2. Click on `nonprofit-learning-backend`
3. Copy the "Service URL"

### 2. NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY

**Should be:** Your Clerk publishable key

**Format:** Starts with `pk_test_` or `pk_live_`

**How to find it:**
1. Go to: https://dashboard.clerk.com
2. Select your application
3. Go to: **API Keys**
4. Copy the **Publishable key**

### 3. NEXT_PUBLIC_CLERK_FRONTEND_API

**Current:** `https://your-app.clerk.accounts.dev` (this is a placeholder)

**Should be:** Your actual Clerk frontend API URL

**Format:** `https://your-actual-app-name.clerk.accounts.dev`

**How to find it:**
1. Go to: https://dashboard.clerk.com
2. Select your application
3. Go to: **Configure** → **Frontend API**
4. Copy the URL (or check the **Domains** section)

**Example:** If your Clerk app is named "nonprofit-learning", it might be:
- `https://nonprofit-learning.clerk.accounts.dev`

## 🔧 How to Fix

### Step 1: Get the Correct Values

Run this script to see what values you need:

```bash
./fix-amplify-env-vars.sh
```

### Step 2: Update Amplify Environment Variables

1. **Go to AWS Amplify Console:**
   - https://console.aws.amazon.com/amplify/home?region=us-east-1
   - Click on your app

2. **Navigate to Environment Variables:**
   - Click **App settings** (left sidebar)
   - Click **Environment variables**

3. **Update each variable:**

   **Variable 1: NEXT_PUBLIC_API_URL**
   - Click **Edit** or **Add variable**
   - Key: `NEXT_PUBLIC_API_URL`
   - Value: Your App Runner URL (from Step 1)
   - Example: `https://abc123xyz.us-east-1.awsapprunner.com`
   - Click **Save**

   **Variable 2: NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY**
   - Key: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
   - Value: Your Clerk publishable key (starts with `pk_test_` or `pk_live_`)
   - Click **Save**

   **Variable 3: NEXT_PUBLIC_CLERK_FRONTEND_API**
   - Key: `NEXT_PUBLIC_CLERK_FRONTEND_API`
   - Value: Your Clerk frontend API URL
   - Example: `https://your-actual-app-name.clerk.accounts.dev`
   - Click **Save**

### Step 3: Redeploy

After updating environment variables:

1. Go to your branch (usually **main**)
2. Click **Actions** (top menu)
3. Click **Redeploy this version**
4. Wait for the build to complete

### Step 4: Verify

1. Open your Amplify URL in a browser
2. Check browser console (F12) for errors
3. Test if the page loads correctly

## 📋 Quick Checklist

- [ ] `NEXT_PUBLIC_API_URL` = Your App Runner backend URL (NOT Clerk URL)
- [ ] `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` = Your Clerk publishable key (from Clerk Dashboard)
- [ ] `NEXT_PUBLIC_CLERK_FRONTEND_API` = Your actual Clerk frontend API URL (NOT placeholder)
- [ ] Redeployed after updating variables
- [ ] Tested the Amplify URL

## 🐛 Common Mistakes

1. **Using Clerk URL for API URL** ❌
   - Wrong: `NEXT_PUBLIC_API_URL = https://your-app.clerk.accounts.dev`
   - Right: `NEXT_PUBLIC_API_URL = https://your-app-runner.us-east-1.awsapprunner.com`

2. **Using placeholder values** ❌
   - Wrong: `https://your-app.clerk.accounts.dev`
   - Right: Your actual Clerk app URL

3. **Forgetting to redeploy** ❌
   - After updating variables, you MUST redeploy for changes to take effect

## 💡 Still Having Issues?

1. **Check build logs:**
   - Amplify Console → Build history → Latest build → View logs

2. **Check browser console:**
   - Open Amplify URL → Press F12 → Check Console tab for errors

3. **Verify backend is running:**
   ```bash
   curl https://your-app-runner-url.us-east-1.awsapprunner.com/health
   ```

4. **Verify Clerk configuration:**
   - Make sure your Amplify URL is added to Clerk's allowed origins
   - Clerk Dashboard → Configure → Allowed origins
