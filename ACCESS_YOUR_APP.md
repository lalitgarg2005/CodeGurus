# How to Access Your Deployed Application

## 🎉 Your App is Deployed!

Since your builds are looking good, here's how to access your application.

## 🌐 Finding Your Amplify URL

### Option 1: AWS Console (Easiest)

1. **Go to AWS Amplify Console:**
   - https://console.aws.amazon.com/amplify/home?region=us-east-1

2. **Click on your app** (e.g., `nonprofit-learning-frontend`)

3. **Find the URL:**
   - Look at the top of the page - you'll see the app URL
   - Format: `https://main.xxxxx.amplifyapp.com`
   - Or check the "Domain" section in the left sidebar

4. **Click the URL** or copy it to your browser

### Option 2: Using AWS CLI

```bash
# Get your Amplify App ID (if you know it)
# Replace YOUR_APP_ID with your actual App ID from GitHub Secrets
aws amplify get-app --app-id YOUR_APP_ID --region us-east-1 \
  --query 'app.defaultDomain' --output text

# Or list all apps and find yours
aws amplify list-apps --region us-east-1 \
  --query 'apps[*].{Name:name,AppId:appId,DefaultDomain:defaultDomain}'
```

### Option 3: Using the Script

```bash
# Run the deployment URLs script
./get-deployment-urls.sh
```

This will show you:
- Backend URL (App Runner)
- Frontend URL (Amplify)
- Other deployment information

## 🔗 Direct Links

### Frontend (Amplify)
- **Format:** `https://main.xxxxx.amplifyapp.com`
- **Find it:** AWS Console → Amplify → Your App → Domain

### Backend (App Runner)
- **Format:** `https://xxxxx.us-east-1.awsapprunner.com`
- **Find it:** AWS Console → App Runner → Services → `nonprofit-learning-backend`

## ✅ Verify Your App is Working

1. **Open the Amplify URL in your browser**
2. **Check the browser console** (F12) for any errors
3. **Test authentication** - try signing in/up
4. **Check API connectivity** - the frontend should connect to your backend

## 🔧 Important: Environment Variables

Make sure your Amplify app has the correct environment variables:

1. **Go to:** AWS Amplify Console → Your App → App settings → Environment variables

2. **Add/Verify these variables:**
   - `NEXT_PUBLIC_API_URL` - Your App Runner backend URL
   - `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` - Your Clerk publishable key
   - `NEXT_PUBLIC_CLERK_FRONTEND_API` - Your Clerk frontend API URL

3. **Redeploy** if you added new variables:
   - Go to the branch (main) → Actions → Redeploy this version

## 🐛 Troubleshooting

### "Cannot connect to backend"
- Check `NEXT_PUBLIC_API_URL` in Amplify environment variables
- Verify your App Runner service is running
- Check CORS settings in your backend

### "Clerk authentication not working"
- Verify `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` is set
- Check `NEXT_PUBLIC_CLERK_FRONTEND_API` is correct
- Make sure Clerk is configured for your Amplify domain

### "Page not found" or blank page
- Check the build logs in Amplify Console
- Verify the build completed successfully
- Check browser console for errors

## 📱 Quick Access Checklist

- [ ] Found Amplify URL in AWS Console
- [ ] Opened URL in browser
- [ ] Verified environment variables are set
- [ ] Tested authentication
- [ ] Verified backend connectivity
- [ ] Checked for console errors

## 🎯 Next Steps

1. **Bookmark your Amplify URL** for easy access
2. **Set up a custom domain** (optional) - see `DOMAIN_SETUP.md`
3. **Share the URL** with your team
4. **Monitor builds** in Amplify Console
