#!/bin/bash
# Bootstrap an Ubuntu EC2 instance for backend deployment
# Installs Docker + AWS CLI, configures user permissions, and enables Docker on boot.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Please run as root (sudo)."
  exit 1
fi

echo "🔧 Updating packages..."
apt-get update -y

echo "🐳 Installing Docker..."
apt-get install -y docker.io
systemctl enable docker
systemctl start docker

echo "☁️  Installing AWS CLI..."
apt-get install -y awscli

TARGET_USER=${SUDO_USER:-ubuntu}
if id "$TARGET_USER" >/dev/null 2>&1; then
  echo "👤 Adding $TARGET_USER to docker group..."
  usermod -aG docker "$TARGET_USER"
fi

cat <<'MSG'
✅ EC2 bootstrap completed.

Next:
1) Log out and log back in so Docker group membership applies.
2) Verify:
   - docker version
   - aws --version
MSG
