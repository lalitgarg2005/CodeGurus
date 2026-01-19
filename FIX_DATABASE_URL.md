# Fix DATABASE_URL Authentication Error

## ❌ Error
```
FATAL: password authentication failed for user "username"
```

## 🔍 Problem

The `DATABASE_URL` in GitHub Secrets has placeholder values:
- Username: `username` (should be `postgres`)
- Password: Likely placeholder or incorrect

## ✅ Solution: Update DATABASE_URL in GitHub Secrets

### Step 1: Find Your RDS Password

The password was set when RDS was created. It could be:

1. **From GitHub Secrets:** Check if `DB_PASSWORD` secret exists
2. **From workflow input:** If you manually triggered the RDS creation workflow
3. **Default:** `ChangeMe123!` (if no password was specified)

### Step 2: Get RDS Endpoint

Your RDS endpoint is:
```
nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com
```

### Step 3: Build Correct DATABASE_URL

Format:
```
postgresql://postgres:PASSWORD@nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com:5432/nonprofit_learning
```

Replace `PASSWORD` with your actual password.

### Step 4: Update GitHub Secret

1. **Go to GitHub Repository:**
   - Navigate to: Settings → Secrets and variables → Actions

2. **Update DATABASE_URL:**
   - Find `DATABASE_URL` secret
   - Click **Update**
   - Paste the correct connection string:
     ```
     postgresql://postgres:YOUR_PASSWORD@nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com:5432/nonprofit_learning
     ```
   - Click **Update secret**

## 🔐 If You Don't Know the Password

### Option 1: Reset RDS Password

```bash
# Reset RDS master password
aws rds modify-db-instance \
  --db-instance-identifier nonprofit-learning-db \
  --master-user-password "YourNewSecurePassword123!" \
  --apply-immediately \
  --region us-east-1
```

Then update `DATABASE_URL` with the new password.

### Option 2: Check GitHub Secrets

Check if `DB_PASSWORD` exists in GitHub Secrets - that's likely the password used.

## 📋 Quick Reference

**RDS Information:**
- **Username:** `postgres`
- **Endpoint:** `nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com`
- **Port:** `5432`
- **Database:** `nonprofit_learning`

**DATABASE_URL Format:**
```
postgresql://postgres:PASSWORD@nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com:5432/nonprofit_learning
```

## ✅ Verify Connection

After updating the secret, re-run the migration workflow. The connection should work.

## 🔒 Security Notes

- **Never commit passwords to code**
- **Use GitHub Secrets** for all sensitive values
- **Consider using AWS Secrets Manager** for production
- **Rotate passwords regularly**

## 🐛 Troubleshooting

### Still Getting Authentication Error?

1. **Verify password is correct:**
   - Check if password has special characters that need URL encoding
   - Special characters in passwords should be URL-encoded:
     - `@` → `%40`
     - `#` → `%23`
     - `$` → `%24`
     - `%` → `%25`
     - `&` → `%26`
     - `+` → `%2B`
     - `=` → `%3D`

2. **Test connection locally:**
   ```bash
   psql "postgresql://postgres:PASSWORD@nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com:5432/nonprofit_learning"
   ```

3. **Check RDS status:**
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier nonprofit-learning-db \
     --query 'DBInstances[0].DBInstanceStatus'
   ```
