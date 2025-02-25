#!/bin/bash

# Ensure the script runs with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Starting Linux Baseline Security Configuration..."

# Disable Unused Services
echo "Disabling unused services..."
systemctl disable --now bluetooth cups rpcbind

# Configure Password Policy
echo "Configuring password policy..."
cat <<EOF > /etc/security/pwquality.conf
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOF

# Install Fail2Ban for SSH Lockout
echo "Installing and enabling Fail2Ban..."
yum install -y fail2ban
systemctl enable --now fail2ban

# Add a Secure User
echo "Creating secure user..."
useradd secureadmin
echo "SecureP@ssw0rd" | passwd --stdin secureadmin
usermod -aG wheel secureadmin

# Configure Sudoers for No Password
echo "Configuring sudo access..."
echo "secureadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable Persistent Logging
echo "Enabling persistent logging..."
sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
systemctl restart systemd-journald

# Configure Firewall Rules
echo "Configuring firewall..."
systemctl enable --now firewalld
firewall-cmd --add-service=ssh --permanent
firewall-cmd --reload

# Set Secure File Permissions
echo "Setting secure file permissions..."
chmod 600 /etc/shadow
chattr +i /etc/passwd

# Check SELinux Status
echo "Checking SELinux Status..."
sestatus

# Install AIDE for Intrusion Detection
echo "Installing AIDE..."
yum install -y aide
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Update System Packages
echo "Updating system packages..."
yum update -y

echo "Baseline Security Configuration Completed!"

# For best results, schedule Bash script as a cron job for ongoing security compliance.
crontab -e

0 2 * * * /path/to/baseline_security.sh >> /var/log/baseline_security.log 2>&1  # To run baseline_security.sh every day at 2 AM


