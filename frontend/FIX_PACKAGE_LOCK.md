# Fix Package Lock File Sync Issue

## Problem
The `package-lock.json` file is out of sync with `package.json`, causing `npm ci` to fail with errors like:
```
Invalid: lock file's @typescript-eslint/parser@6.21.0 does not satisfy @typescript-eslint/parser@8.53.0
```

## Quick Fix (For CI/CD)
The GitHub Actions workflows have been updated to automatically handle this:
- They will detect when the lock file is out of sync
- Automatically regenerate the lock file during deployment
- This allows deployments to continue working

## Permanent Fix (Recommended)
To fix this properly and prevent future issues:

### Option 1: Update Lock File Locally (Recommended)

```bash
cd frontend

# Remove the old lock file
rm package-lock.json

# Reinstall dependencies (this will generate a new lock file)
npm install --legacy-peer-deps

# Verify the lock file was created
ls -la package-lock.json

# Commit the updated lock file
git add package-lock.json
git commit -m "Update package-lock.json to sync with package.json"
git push
```

### Option 2: Update Dependencies

If you want to update to the latest compatible versions:

```bash
cd frontend

# Update all dependencies to latest compatible versions
npm update --legacy-peer-deps

# Or update specific packages
npm install @typescript-eslint/parser@latest --legacy-peer-deps --save-dev

# Commit the changes
git add package.json package-lock.json
git commit -m "Update dependencies and lock file"
git push
```

## Why This Happened

The lock file (`package-lock.json`) got out of sync with `package.json` because:
1. Dependencies were updated in `package.json` but the lock file wasn't regenerated
2. Dependencies were installed with different npm versions
3. Manual edits to `package.json` without updating the lock file

## Best Practices

1. **Always commit `package-lock.json`** - This ensures consistent installs across environments
2. **Use `npm install` when adding/updating packages** - This automatically updates the lock file
3. **Use `npm ci` in CI/CD** - But only when the lock file is in sync
4. **Run `npm install` after pulling changes** - If someone updated dependencies

## Verification

After updating the lock file, verify it works:

```bash
cd frontend

# Clean install to verify lock file is correct
rm -rf node_modules
npm ci --legacy-peer-deps

# If this succeeds, the lock file is in sync!
```

## Current Workflow Behavior

The GitHub Actions workflows now:
1. Try `npm ci` first (for faster, deterministic installs)
2. If that fails due to lock file mismatch, automatically:
   - Remove the old lock file
   - Run `npm install` to regenerate it
   - Continue with the build

This ensures deployments work even if the lock file is temporarily out of sync, but you should still fix it locally and commit the updated lock file.
