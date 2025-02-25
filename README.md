# Baseline & Security Experience for Linux (RHEL 8 and Others)

To maintain a secure and stable Linux environment, a strong baseline configuration and security best practices are essential. Below is a breakdown of baseline security measures and experience areas needed for Linux security administration.

---

## 1. Baseline Configuration for Linux Security

A baseline configuration refers to the minimum security standards implemented on a Linux system to ensure integrity, confidentiality, and availability.

### 1.1. System Hardening Best Practices
- Disable Unused Services
```bash
sudo systemctl disable --now <service_name>
```

- Set Strong Password Policies (/etc/security/pwquality.conf)
```bash
sudo vi /etc/security/pwquality.conf
```

- Add:
```plaintext 
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
```

- Lock Out Failed SSH Login Attempts (Using fail2ban)
```bash
sudo yum install fail2ban -y
sudo systemctl enable --now fail2ban
```

---

## 2. Linux Security Experience Areas

### 2.1. Access Control & Privilege Management
- Managing Users & Groups
```bash
sudo useradd username
sudo passwd username
sudo usermod -aG wheel username  # Add user to sudo group
```

- Configuring Sudo Permissions (/etc/sudoers)
```bash
sudo visudo
```

- Add:
```plaintext
username ALL=(ALL) NOPASSWD: ALL
```

- Implementing PAM (Pluggable Authentication Modules)
```bash
sudo cat /etc/pam.d/sshd
```

### 2.2. Logging & Monitoring
- System Logs (journalctl)
```bash
sudo journalctl -xe
```

- Authentication Logs
```bash
sudo cat /var/log/secure | grep "Failed"
```

- Real-Time Log Monitoring
```bash
sudo tail -f /var/log/messages
```

### 2.3. Security Policies & Compliance
- Applying Security Baselines (CIS Benchmark, DISA STIG, NIST 800-53)
- Checking Compliance with OpenSCAP
```bash
sudo yum install scap-security-guide -y
sudo oscap xccdf eval --profile cis /usr/share/xml/scap/ssg/content/ssg-rhel8-xccdf.xml
```

### 2.4. Network Security & Firewalls
- Check Active Firewall Rules
```bash
sudo firewall-cmd --list-all
```

- Allow or Block Ports
```bash
sudo firewall-cmd --add-port=22/tcp --permanent
sudo firewall-cmd --reload
```

- Monitor Network Traffic
```bash
sudo netstat -tulnp
sudo ss -tulnp
```

### 2.5. File System Security
- Restrict File Permissions
```bash
sudo chmod 600 /etc/shadow
```

- Use chattr to Prevent Modification
```bash
sudo chattr +i /etc/passwd
```

### 2.6. SELinux & AppArmor
- Check SELinux Status
```bash
sestatus
```

- List SELinux Denials
```bash
sudo ausearch -m AVC
```

- Temporarily Disable SELinux (For Testing)
```bash
sudo setenforce 0
```

### 2.7. Patching & Vulnerability Management
- Check Installed Package Versions
```bash
rpm -qa | grep <package_name>
```

- Update All Packages
```bash
sudo yum update -y
```

- Check for Vulnerabilities
```bash
sudo yum install yum-utils -y
sudo yum updateinfo
```

### 2.8. Intrusion Detection & Prevention
- Use AIDE (Advanced Intrusion Detection Environment)
```bash
sudo yum install aide -y
sudo aide --init
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
sudo aide --check
```

---
## Scheduling Ansible or Bash Script as a Cron Job for Ongoing Security Compliance

- To ensure continuous enforcement of security policies, you can schedule the Ansible playbook or Bash script as a cron job on RHEL 8.

### 1. Scheduling the Bash Script as a Cron Job

#### Step 1: Open the Crontab

- Run:
```bash
crontab -e
```

#### Step 2: Add a Cron Job to Execute the Bash Script

- To run baseline_security.sh every day at 2 AM, add:
```plaintext
0 2 * * * /path/to/baseline_security.sh >> /var/log/baseline_security.log 2>&1
```

- 0 2 * * * → Runs at** 2 AM dail**y.
- >> /var/log/baseline_security.log 2>&1 → Logs output to a file.

#### Step 3: Save and Exit
- If using nano, press CTRL+X, then Y, and Enter to save.
- If using vi, press ESC, type :wq, and hit Enter.

#### Step 4: Verify the Cron Job

- Check existing cron jobs:
```bash
crontab -l
```

### 2. Scheduling the Ansible Playbook as a Cron Job

#### Step 1: Create a Shell Script to Run Ansible

- Create a script /usr/local/bin/run_ansible_baseline.sh:
```bash
#!/bin/bash
ansible-playbook -i /path/to/inventory /path/to/baseline_security.yml >> /var/log/ansible_baseline.log 2>&1
```

- Make it executable:
```bash
chmod +x /usr/local/bin/run_ansible_baseline.sh
```

#### Step 2: Add a Cron Job

- Run:
```bash
crontab -e
```
- Add:
```plantext
30 3 * * * /usr/local/bin/run_ansible_baseline.sh
```

- Runs at 3:30 AM daily.

#### Step 3: Verify the Cron Job
```bash
crontab -l
```

### 3. Using Systemd Timer as an Alternative

- Instead of cron, systemd timers can be used.

#### Step 1: Create a Systemd Service

- Create /etc/systemd/system/baseline_security.service:
```plaintext
[Unit]
Description=Run Baseline Security Enforcement
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/run_ansible_baseline.sh
```

#### Step 2: Create a Systemd Timer

- Create /etc/systemd/system/baseline_security.timer:
```plaintext
[Unit]
Description=Schedule Baseline Security Enforcement

[Timer]
OnCalendar=03:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

#### Step 3: Enable and Start the Timer
```bash
sudo systemctl enable --now baseline_security.timer
```

#### Step 4: Check Timer Status
```bash
sudo systemctl list-timers --all
```


---
## Final Thoughts

A strong Linux security baseline involves hardening access controls, monitoring logs, enforcing compliance policies, securing networks, and applying regular updates. Having hands-on experience in these areas ensures system security on RHEL 8 and other Linux distributions.

**For advanced security**, consider using:

✔ SELinux Policie

✔ Tripwire for Intrusion Detection

✔ Ansible for Security Automation

✔ SIEM Solutions (Splunk, ELK, Wazuh)

