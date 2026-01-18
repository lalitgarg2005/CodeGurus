# AWS Amplify Setup Guide

## Problem
The Amplify deployment is failing because `AMPLIFY_APP_ID` is not set in GitHub Secrets.

## Solution

You need to either:
1. **Create an Amplify app** and get its App ID
2. **Or use an existing Amplify app** and get its App ID

## Option 1: Create Amplify App via AWS Console (Recommended)

1. **Go to AWS Amplify Console:**
   - https://console.aws.amazon.com/amplify/home?region=us-east-1

2. **Create a new app:**
   - Click "New app" → "Host web app"
   - Choose "GitHub" as your source
   - Authorize AWS Amplify to access your GitHub repository
   - Select your repository: `CodeGurus`
   - Select branch: `main`
   - App name: `nonprofit-learning-frontend` (or any name)

3. **Configure build settings:**
   - Amplify will auto-detect Next.js
   - Build settings should be:
     ```yaml
     version: 1
     frontend:
       phases:
         preBuild:
           commands:
             - npm install --legacy-peer-deps --no-audit
         build:
           commands:
             - npm run build
       artifacts:
         baseDirectory: .next
         files:
           - '**/*'
       cache:
         paths:
           - node_modules/**/*
     ```

4. **Get the App ID:**
   - After creating the app, go to App settings → General
   - Copy the "App ID" (format: `d1234567890`)

5. **Add to GitHub Secrets:**
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `AMPLIFY_APP_ID`
   - Value: Your App ID (e.g., `d1234567890`)
   - Click "Add secret"

## Option 2: Create Amplify App via AWS CLI

```bash
# Create Amplify app
aws amplify create-app \
  --name nonprofit-learning-frontend \
  --region us-east-1

# This will output the App ID - copy it
# Add it to GitHub Secrets as AMPLIFY_APP_ID
```

Then connect it to your GitHub repository:
1. Go to AWS Amplify Console
2. Select your app
3. Click "Connect branch"
4. Connect to your GitHub repository and `main` branch

## Option 3: Use Existing Amplify App

If you already have an Amplify app:

1. **Get the App ID:**
   ```bash
   # List all Amplify apps
   aws amplify list-apps --region us-east-1
   
   # Get specific app details
   aws amplify get-app --app-id YOUR_APP_ID --region us-east-1
   ```

2. **Or find it in AWS Console:**
   - Go to AWS Amplify Console
   - Click on your app
   - Go to App settings → General
   - Copy the "App ID"

3. **Add to GitHub Secrets:**
   - GitHub → Settings → Secrets → Actions
   - Add `AMPLIFY_APP_ID` with your App ID value

## Verify Setup

After adding the secret, the workflow will:
1. Check if `AMPLIFY_APP_ID` is set
2. Trigger an Amplify build
3. Show build status

## Troubleshooting

### Error: "App ID not found"
- Verify the App ID is correct
- Check it exists: `aws amplify get-app --app-id YOUR_APP_ID --region us-east-1`

### Error: "Branch not found"
- Make sure the branch `main` exists in your Amplify app
- Connect the branch in Amplify Console if needed

### Error: "Permission denied"
- Ensure your IAM user has Amplify permissions
- Add `AmplifyFullAccess` policy to your IAM user

## Next Steps

After setting up Amplify:
1. The workflow will automatically trigger builds on push to `main`
2. Check build status in AWS Amplify Console
3. Access your app at the Amplify URL (e.g., `https://main.xxxxx.amplifyapp.com`)
4. Update `NEXT_PUBLIC_API_URL` in Amplify environment variables to point to your backend

## Amplify Environment Variables

In Amplify Console → App settings → Environment variables, add:
- `NEXT_PUBLIC_API_URL` - Your backend API URL (App Runner service URL)
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` - Your Clerk publishable key
- `NEXT_PUBLIC_CLERK_FRONTEND_API` - Your Clerk frontend API URL

These will be available during the build process.
