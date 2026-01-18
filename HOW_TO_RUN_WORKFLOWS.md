# How to Run GitHub Actions Workflows

## 🚀 Running Workflows Manually

### Option 1: Using "Full Deployment to AWS" (Recommended)

This workflow can deploy everything and has manual trigger:

1. **Go to GitHub Actions:**
   - Your repository → **Actions** tab

2. **Find "Full Deployment to AWS":**
   - Click on it in the left sidebar

3. **Click "Run workflow":**
   - Click the **Run workflow** dropdown (top right)
   - Select branch: `main`
   - Choose options:
     - Deploy Backend: `true`
     - Deploy Frontend: `false` (or `true` if you want both)
   - Click **Run workflow**

### Option 2: Using "Deploy Backend to AWS" (After Update)

After the workflow is updated, you can run it directly:

1. **Go to GitHub Actions:**
   - Your repository → **Actions** tab

2. **Find "Deploy Backend to AWS":**
   - Click on it in the left sidebar

3. **Click "Run workflow":**
   - Click the **Run workflow** button (top right)
   - Select branch: `main`
   - Click **Run workflow**

### Option 3: Trigger by Pushing Code

If manual trigger isn't available, trigger by pushing code:

```bash
# Make a small change to trigger deployment
cd backend
touch .deploy-trigger
git add .
git commit -m "Trigger backend deployment"
git push origin main
```

## 📋 Workflow Status

### "Deploy Backend to AWS"
- ✅ **Now supports manual trigger** (after update)
- ✅ Runs on push to `main` when `backend/**` changes
- ✅ Can be triggered manually via `workflow_dispatch`

### "Full Deployment to AWS"
- ✅ **Supports manual trigger**
- ✅ Can deploy backend, frontend, or both
- ✅ Has input options for what to deploy

## 🔍 If "Run workflow" Button is Missing

If you don't see the "Run workflow" button:

1. **Check workflow file:**
   - Make sure it has `workflow_dispatch:` in the `on:` section
   - The workflow file must be in `.github/workflows/` directory

2. **Check branch:**
   - Make sure you're on the `main` branch
   - The workflow file must be committed to the repository

3. **Check permissions:**
   - You need write access to the repository
   - If it's a private repo, you need to be a collaborator

4. **Refresh the page:**
   - Sometimes GitHub needs a moment to detect the workflow

## ✅ After Running Workflow

1. **Watch the progress:**
   - Click on the workflow run
   - Watch each step complete

2. **Check for errors:**
   - Red X = Failed step
   - Click on the step to see error details

3. **Verify deployment:**
   - Check App Runner Console for the service
   - Get the service URL
   - Use it in Amplify environment variables

## 🐛 Troubleshooting

### "No workflows found"
- Make sure workflow files are in `.github/workflows/` directory
- Make sure they're committed to the repository
- Check the file has correct YAML syntax

### "Run workflow button not showing"
- The workflow might not have `workflow_dispatch` trigger
- Try using "Full Deployment to AWS" instead
- Or trigger by pushing code

### "Workflow fails immediately"
- Check GitHub Secrets are set correctly
- Check AWS credentials are valid
- Check IAM permissions

## 📖 Quick Reference

**Full Deployment:** Actions → Full Deployment to AWS → Run workflow

**Backend Only:** Actions → Deploy Backend to AWS → Run workflow (after update)

**Trigger by Push:** Make a commit to `backend/` folder and push to `main`
