# Deploy Backend to EC2

This repo now deploys the backend to **EC2** (instead of App Runner). The workflow builds a Docker image, pushes to ECR, and pulls it on your EC2 instance.

## ✅ Prerequisites

### 1) EC2 instance
- Ubuntu 22.04 (t2.micro or t3.micro)
- Inbound security group rules:
  - TCP **22** from your IP
  - TCP **8000** from `0.0.0.0/0` (or your Amplify/CloudFront IPs)
- Outbound: allow all (default)

### 2) IAM role on EC2
Attach an instance role with **ECR read** permissions:
- `AmazonEC2ContainerRegistryReadOnly`

### 3) Docker + AWS CLI on EC2
On the instance:
```bash
sudo apt-get update
sudo apt-get install -y docker.io awscli
sudo usermod -aG docker $USER
# log out and back in
```

### 4) GitHub Secrets
Add these secrets in GitHub → Settings → Secrets and variables → Actions:
- `EC2_HOST` (public IP or DNS)
- `EC2_USER` (usually `ubuntu`)
- `EC2_SSH_KEY` (private key contents)
- `EC2_SSH_PORT` (optional, default `22`)
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DATABASE_URL`
- `CLERK_SECRET_KEY`
- `CLERK_PUBLISHABLE_KEY`
- `CLERK_FRONTEND_API`
- `CORS_ORIGINS`

## 🚀 Deployment

### Option A: Full Deployment
Run the `Full Deployment to AWS` workflow.

### Option B: Backend Only
Run the `Deploy Backend to AWS` workflow.

Both workflows will:
1. Build the backend Docker image
2. Push to ECR
3. SSH into EC2 and run the container

## ✅ Verify

```bash
curl http://<EC2_PUBLIC_IP>:8000/health
```

If it returns `{ "status": "healthy" }`, the backend is live.

## ⚠️ Notes

- If you change the backend image, **re-run the workflow** to pull the latest image on EC2.
- If database is unreachable at startup, the app will still start; check logs later.
- For production, consider moving secrets to SSM Parameter Store.
