# Manual Tasks for EC2 Deployment

## 1) Create EC2 Instance
- Ubuntu 22.04 (t2.micro / t3.micro)
- Assign a public IPv4
- Key pair: download private key

## 2) Security Group (Initial)
- Allow inbound TCP **22** from your IP
- Allow inbound TCP **8000** from your IP (temporarily)

## 3) Install Dependencies on EC2
SSH into EC2:
```bash
ssh -i <key.pem> ubuntu@<EC2_PUBLIC_IP>
```
Run:
```bash
sudo ./ec2-bootstrap.sh
```

## 4) Attach IAM Role to EC2
Attach managed policy:
- `AmazonEC2ContainerRegistryReadOnly`

## 5) Add GitHub Secrets
Set these in GitHub → Settings → Secrets and variables → Actions:
- `EC2_HOST`
- `EC2_USER` (ubuntu)
- `EC2_SSH_KEY` (private key contents)
- `EC2_SSH_PORT` (optional, default 22)
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DATABASE_URL`
- `CLERK_SECRET_KEY`
- `CLERK_PUBLISHABLE_KEY`
- `CLERK_FRONTEND_API`
- `CORS_ORIGINS`

## 6) Tighten Security Group (Production)
After frontend is live, limit inbound:
```bash
./tighten-ec2-security-group.sh
```
- SSH: your IP/32
- App: Amplify/CloudFront IPs or your corporate NAT

## 7) Deploy Backend
Run GitHub Actions workflow:
- `Deploy Backend to AWS`

## 8) Verify
```bash
curl http://<EC2_PUBLIC_IP>:8000/health
```

## 9) Update Frontend
Set Amplify env:
- `NEXT_PUBLIC_API_URL=http://<EC2_PUBLIC_IP>:8000`

## 10) Optional DNS + TLS
- Put backend behind ALB + ACM cert
- Restrict EC2 inbound to ALB security group

