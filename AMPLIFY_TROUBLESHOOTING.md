# Amplify URL Not Loading - Troubleshooting Guide

## Common Issues and Fixes

### 1. Missing Environment Variables in Amplify

**Problem:** The build succeeds but the page doesn't load or shows errors.

**Solution:** Environment variables must be set in **Amplify Console**, not just GitHub Secrets!

1. **Go to AWS Amplify Console:**
   - https://console.aws.amazon.com/amplify/home?region=us-east-1
   - Click on your app

2. **Navigate to Environment Variables:**
   - App settings → Environment variables

3. **Add/Verify these variables:**
   ```
   NEXT_PUBLIC_API_URL=https://your-app-runner-url.us-east-1.awsapprunner.com
   NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxxxx or pk_live_xxxxx
   NEXT_PUBLIC_CLERK_FRONTEND_API=https://your-app.clerk.accounts.dev
   ```

4. **Redeploy after adding variables:**
   - Go to your branch (main)
   - Click "Actions" → "Redeploy this version"

### 2. Incorrect NEXT_PUBLIC_API_URL

**Problem:** Frontend can't connect to backend.

**How to check:**
1. Get your App Runner service URL:
   ```bash
   aws apprunner list-services --region us-east-1 \
     --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
     --output text
   ```

2. Verify it matches `NEXT_PUBLIC_API_URL` in Amplify environment variables

3. Test the backend URL:
   ```bash
   curl https://your-app-runner-url.us-east-1.awsapprunner.com/health
   ```

**Fix:** Update `NEXT_PUBLIC_API_URL` in Amplify environment variables to match your App Runner URL.

### 3. CORS Issues

**Problem:** Browser console shows CORS errors.

**Solution:** Update `CORS_ORIGINS` in your backend (App Runner) to include your Amplify URL.

1. **Get your Amplify URL:**
   - Format: `https://main.xxxxx.amplifyapp.com`

2. **Update GitHub Secret `CORS_ORIGINS`:**
   - Go to GitHub → Settings → Secrets → Actions
   - Update `CORS_ORIGINS` to include your Amplify URL:
     ```
     https://main.xxxxx.amplifyapp.com,https://your-backend-url.us-east-1.awsapprunner.com
     ```

3. **Redeploy backend** to apply CORS changes

### 4. Clerk Configuration Issues

**Problem:** Authentication doesn't work.

**Check:**
1. **Verify Clerk keys are correct:**
   - `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` should start with `pk_test_` or `pk_live_`
   - `NEXT_PUBLIC_CLERK_FRONTEND_API` should be your Clerk frontend API URL

2. **Add Amplify URL to Clerk:**
   - Go to Clerk Dashboard → Configure → Allowed origins
   - Add your Amplify URL: `https://main.xxxxx.amplifyapp.com`

### 5. Build Errors

**Problem:** Build succeeds but page is blank or shows errors.

**Check build logs:**
1. Go to Amplify Console → Your App → Build history
2. Click on the latest build
3. Check for errors in the build logs
4. Look for:
   - Missing environment variables
   - Build failures
   - TypeScript errors

### 6. Browser Console Errors

**Problem:** Page loads but shows errors in browser.

**How to check:**
1. Open your Amplify URL in browser
2. Press F12 to open Developer Tools
3. Check Console tab for errors
4. Check Network tab for failed requests

**Common errors:**
- `Failed to fetch` → Backend URL incorrect or CORS issue
- `Clerk error` → Clerk keys incorrect or domain not allowed
- `404 Not Found` → Route not found, check Next.js routing

## Verification Checklist

Use the verification script:

```bash
./verify-amplify-config.sh
```

Or manually check:

- [ ] Amplify app exists and is accessible
- [ ] `NEXT_PUBLIC_API_URL` is set in Amplify environment variables
- [ ] `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` is set and correct
- [ ] `NEXT_PUBLIC_CLERK_FRONTEND_API` is set and correct
- [ ] Backend (App Runner) is running and accessible
- [ ] CORS_ORIGINS includes Amplify URL
- [ ] Latest build completed successfully
- [ ] No errors in browser console
- [ ] Clerk domain is configured for Amplify URL

## Quick Fix Steps

1. **Get your Amplify URL:**
   ```bash
   aws amplify get-app --app-id YOUR_APP_ID --region us-east-1 \
     --query 'app.defaultDomain' --output text
   ```
   URL format: `https://main.xxxxx.amplifyapp.com`

2. **Get your App Runner URL:**
   ```bash
   aws apprunner list-services --region us-east-1 \
     --query "ServiceSummaryList[?ServiceName=='nonprofit-learning-backend'].ServiceUrl" \
     --output text
   ```

3. **Set Amplify environment variables:**
   - Go to Amplify Console → Your App → App settings → Environment variables
   - Add:
     - `NEXT_PUBLIC_API_URL` = Your App Runner URL
     - `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` = Your Clerk publishable key
     - `NEXT_PUBLIC_CLERK_FRONTEND_API` = Your Clerk frontend API URL

4. **Update CORS_ORIGINS:**
   - Update GitHub Secret `CORS_ORIGINS` to include Amplify URL
   - Redeploy backend

5. **Redeploy Amplify:**
   - Amplify Console → Branch (main) → Actions → Redeploy this version

6. **Test:**
   - Open Amplify URL in browser
   - Check browser console (F12) for errors
   - Test authentication

## Still Not Working?

1. **Check Amplify build logs** for specific errors
2. **Check browser console** (F12) for client-side errors
3. **Test backend directly** to ensure it's working
4. **Verify all URLs** are correct (no typos, correct protocol)
5. **Check network tab** in browser DevTools for failed requests
