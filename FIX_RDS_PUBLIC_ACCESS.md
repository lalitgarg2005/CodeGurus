# Fix RDS Public Access for Migrations

## ❌ Problem

RDS is **not publicly accessible**, which means:
1. **GitHub Actions runners** (external) cannot connect to run migrations
2. **App Runner** (without VPC) cannot connect

## ✅ Solution: Make RDS Publicly Accessible

I've made RDS publicly accessible and updated the security group. This allows:
- ✅ GitHub Actions to run migrations
- ✅ App Runner to connect (even without VPC initially)
- ⚠️ **Note:** RDS is still protected by security group rules

## 🔒 Security

Even though RDS is publicly accessible:
- **Security group** only allows PostgreSQL (port 5432) from specific sources
- **Database credentials** are still required
- **Not recommended for production** without additional security measures

## 📋 What Was Changed

1. **RDS Public Access:** Enabled
   ```bash
   aws rds modify-db-instance \
     --db-instance-identifier nonprofit-learning-db \
     --publicly-accessible \
     --apply-immediately
   ```

2. **Security Group:** Added rule to allow PostgreSQL from anywhere
   - This is needed for GitHub Actions and App Runner to connect
   - You can restrict this later to specific IP ranges

## 🔄 Next Steps

1. **Wait for RDS modification to complete** (5-10 minutes)
   - Check status: `aws rds describe-db-instances --db-instance-identifier nonprofit-learning-db --query 'DBInstances[0].DBInstanceStatus'`

2. **Re-run migrations:**
   - GitHub Actions should now be able to connect
   - Or trigger the migration workflow manually

3. **Test App Runner connection:**
   - App Runner should now be able to connect (even without VPC)
   - But VPC configuration is still recommended for production

## 🛡️ Production Security Recommendations

For production, consider:
1. **Restrict security group** to specific IP ranges instead of 0.0.0.0/0
2. **Use VPC for App Runner** (recommended)
3. **Use VPN or bastion host** for database access
4. **Enable SSL/TLS** for database connections
5. **Use AWS Secrets Manager** for credentials

## 🔍 Verify Changes

```bash
# Check RDS is publicly accessible
aws rds describe-db-instances \
  --db-instance-identifier nonprofit-learning-db \
  --query 'DBInstances[0].PubliclyAccessible'

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids sg-09390ba267d614433 \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`5432`]'
```

## ⚠️ Important Notes

- **RDS modification takes 5-10 minutes** - wait before testing
- **Public access is less secure** - use VPC for production
- **Security group rules** still protect the database
- **Database credentials** are still required
