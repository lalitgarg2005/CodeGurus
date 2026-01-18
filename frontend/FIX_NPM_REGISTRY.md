# Fix NPM Private Registry Authentication Issue

## Problem
The frontend deployment is failing with:
```
npm error code E401
npm error Incorrect or missing password.
```

## Root Cause
The `package-lock.json` file contains references to a **private JFrog Artifactory registry**:
- `https://mckinsey.jfrog.io/artifactory/api/npm/npm/`

This private registry requires authentication, which is not available in GitHub Actions. All the packages in `package.json` are public packages available on the public npm registry.

## Temporary Fix (Already Applied)
The GitHub Actions workflows have been updated to:
1. Set npm to use the public registry: `https://registry.npmjs.org/`
2. Replace private registry URLs in `package-lock.json` with public registry URLs
3. Skip npm audit (which might require authentication)

This allows deployments to work without authentication.

## Permanent Fix (Recommended)

To fix this permanently, regenerate `package-lock.json` using the public npm registry:

### Option 1: Regenerate Lock File Locally

```bash
cd frontend

# Remove old lock file
rm package-lock.json

# Set npm to use public registry
npm config set registry https://registry.npmjs.org/

# Remove any private registry configuration
npm config delete //mckinsey.jfrog.io/artifactory/api/npm/npm/:_authToken || true

# Reinstall dependencies (this will generate a new lock file with public registry)
npm install --legacy-peer-deps

# Verify the lock file uses public registry
grep -i "mckinsey.jfrog.io" package-lock.json || echo "✅ No private registry found - good!"

# Commit the updated lock file
git add package-lock.json
git commit -m "Update package-lock.json to use public npm registry"
git push
```

### Option 2: Use sed to Replace URLs

```bash
cd frontend

# Replace private registry URLs with public registry
sed -i '' 's|https://mckinsey.jfrog.io/artifactory/api/npm/npm/|https://registry.npmjs.org/|g' package-lock.json

# Verify changes
grep -i "mckinsey.jfrog.io" package-lock.json || echo "✅ No private registry found - good!"

# Commit the updated lock file
git add package-lock.json
git commit -m "Update package-lock.json to use public npm registry"
git push
```

## Why This Happened

The `package-lock.json` was likely generated on a machine that had:
- A `.npmrc` file configured to use the private JFrog Artifactory registry
- npm configured to use the private registry for all packages

Even though all packages in `package.json` are public, the lock file preserved the private registry URLs.

## Verification

After fixing, verify the lock file:

```bash
# Check for private registry references
grep -i "mckinsey.jfrog.io" package-lock.json

# Should return nothing (no matches)
# If it returns matches, the fix didn't work
```

## Current Workflow Behavior

The GitHub Actions workflows now:
1. **Automatically replace** private registry URLs with public registry URLs
2. **Set npm registry** to the public registry
3. **Skip authentication** requirements

This ensures deployments work even if the lock file has private registry references, but you should still fix it locally and commit the updated lock file.

## If You Need Private Packages

If you actually need packages from the private registry:
1. Add authentication tokens to GitHub Secrets
2. Configure `.npmrc` in the workflow to authenticate
3. Keep the private registry URLs in `package-lock.json`

But for this project, all packages are public, so using the public registry is the correct solution.
