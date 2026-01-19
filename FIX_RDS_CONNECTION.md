# Fix RDS Connection Timeout

## ❌ Error
```
OperationalError: connection to server at "nonprofit-learning-db.cmb6i86sehtx.us-east-1.rds.amazonaws.com" (172.31.70.67), port 5432 failed: Connection timed out
```

## 🔍 Problem

App Runner cannot connect to RDS because:
1. **App Runner is not configured for VPC access** - By default, App Runner runs in AWS-managed VPC
2. **RDS security group** only allows access from the VPC CIDR, not from App Runner
3. **Network isolation** - App Runner and RDS are in different network contexts

## ✅ Solution

### Option 1: Configure App Runner VPC Access (Recommended)

App Runner needs to be configured to access your VPC where RDS is located.

1. **Get your VPC ID and Subnets:**
   ```bash
   # Get VPC ID
   aws rds describe-db-instances \
     --db-instance-identifier nonprofit-learning-db \
     --region us-east-1 \
     --query 'DBInstances[0].DBSubnetGroup.VpcId' \
     --output text
   
   # Get Subnet IDs
   aws rds describe-db-subnet-groups \
     --db-subnet-group-name nonprofit-learning-db-subnet-group \
     --region us-east-1 \
     --query 'DBSubnetGroups[0].Subnets[*].SubnetIdentifier' \
     --output text
   ```

2. **Update App Runner Service with VPC Configuration:**
   
   You need to update the App Runner service to include VPC configuration. This requires:
   - VPC ID
   - Subnet IDs (at least 2 in different AZs)
   - Security group that allows outbound to RDS

3. **Update RDS Security Group:**
   - Allow inbound from App Runner's security group (not just VPC CIDR)

### Option 2: Update RDS Security Group (Quick Fix)

Allow App Runner to access RDS by updating the security group:

1. **Get App Runner's security group** (if it has VPC access configured)
2. **Or allow from App Runner's IP range** (less secure)

### Option 3: Use Public RDS (Not Recommended for Production)

For testing only, you could make RDS publicly accessible, but this is **NOT recommended** for production.

## 🔧 Step-by-Step Fix

### Step 1: Get VPC Information

```bash
# Get RDS VPC ID
RDS_VPC=$(aws rds describe-db-instances \
  --db-instance-identifier nonprofit-learning-db \
  --region us-east-1 \
  --query 'DBInstances[0].DBSubnetGroup.VpcId' \
  --output text)

echo "RDS VPC: $RDS_VPC"

# Get Subnets
aws rds describe-db-subnet-groups \
  --db-subnet-group-name nonprofit-learning-db-subnet-group \
  --region us-east-1 \
  --query 'DBSubnetGroups[0].Subnets[*].{SubnetId:SubnetIdentifier,AvailabilityZone:SubnetAvailabilityZone}' \
  --output table
```

### Step 2: Create Security Group for App Runner

```bash
# Create security group for App Runner
APP_RUNNER_SG=$(aws ec2 create-security-group \
  --group-name nonprofit-learning-apprunner-sg \
  --description "Security group for App Runner to access RDS" \
  --vpc-id $RDS_VPC \
  --region us-east-1 \
  --query 'GroupId' \
  --output text)

echo "App Runner Security Group: $APP_RUNNER_SG"
```

### Step 3: Update RDS Security Group

Allow App Runner's security group to access RDS:

```bash
# Get RDS security group
RDS_SG="sg-09390ba267d614433"

# Allow App Runner security group to access RDS
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG \
  --protocol tcp \
  --port 5432 \
  --source-group $APP_RUNNER_SG \
  --region us-east-1
```

### Step 4: Update App Runner Service with VPC Configuration

This requires updating the App Runner service configuration. You'll need to:

1. **Get subnet IDs** (at least 2 in different AZs)
2. **Update App Runner service** with VPC configuration

**Note:** App Runner VPC configuration can only be set during service creation or via a service update that includes network configuration.

## 🚀 Quick Fix Script

I'll create a script to help you fix this:

```bash
./fix-rds-connection.sh
```

## 📋 Alternative: Use AWS Console

### Update RDS Security Group via Console

1. **Go to EC2 Console:**
   - https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:
   - Find security group: `sg-09390ba267d614433`

2. **Edit Inbound Rules:**
   - Click **Edit inbound rules**
   - Click **Add rule**
   - Type: **PostgreSQL**
   - Port: **5432**
   - Source: 
     - Option A: **Custom** → Select App Runner's security group (if exists)
     - Option B: **Anywhere-IPv4** (0.0.0.0/0) - **NOT recommended for production**
   - Click **Save rules**

### Configure App Runner VPC Access

1. **Go to App Runner Console:**
   - https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
   - Click on `nonprofit-learning-backend`

2. **Configure VPC:**
   - Go to **Configuration** → **Networking**
   - Click **Edit**
   - Enable **VPC connector**
   - Select your VPC and subnets
   - Select security group
   - Click **Save**

## ⚠️ Important Notes

1. **App Runner VPC Configuration:**
   - Requires at least 2 subnets in different Availability Zones
   - Can only be configured during service creation or via update
   - May require service recreation

2. **Security Best Practices:**
   - Don't use `0.0.0.0/0` for RDS access
   - Use security group references instead of CIDR blocks
   - Keep RDS in private subnets

3. **Network Requirements:**
   - App Runner and RDS must be in the same VPC (or connected VPCs)
   - Security groups must allow traffic between them

## 🐛 Troubleshooting

### Still Can't Connect?

1. **Check security group rules:**
   ```bash
   aws ec2 describe-security-groups \
     --group-ids sg-09390ba267d614433 \
     --region us-east-1 \
     --query 'SecurityGroups[0].IpPermissions'
   ```

2. **Check RDS is accessible:**
   - RDS status should be "Available"
   - Check if RDS is in a public subnet (if you want public access)

3. **Check App Runner VPC configuration:**
   - App Runner must have VPC access configured
   - Check if App Runner is in the same VPC as RDS

4. **Test connection from App Runner:**
   - Check App Runner logs for connection errors
   - Verify DATABASE_URL is correct

## 📖 Next Steps

After fixing the connection:

1. **Re-run migrations** - They should work now
2. **Test backend** - Health check should work
3. **Verify database** - Check if tables are created
