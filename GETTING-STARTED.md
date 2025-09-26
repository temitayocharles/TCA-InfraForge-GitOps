# 🚀 TCA-InfraForge: Quick Start Guide
**Get your professional GitOps platform running in 10 minutes!**

---

## 🎯 What You'll Get

✅ **Professional ArgoCD Dashboard** - 24/7 remote access  
✅ **Complete Monitoring Suite** - Grafana + Prometheus  
✅ **Enterprise Security** - Auto-generated passwords & SSL  
✅ **$1.70/month** - Less than a coffee for professional platform!

---

## 📋 Before You Start (2 minutes)

**You need 3 things:**

### 1️⃣ Oracle Cloud Account
- 🆓 **Free to create**: [oracle.com/cloud/free](https://www.oracle.com/cloud/free/)
- 💳 **Enable PAYG billing** (required for 2GB VM)
- 💰 **Cost**: ~$1.70/month total

### 2️⃣ GitHub Account  
- 🆓 **Free account**: [github.com](https://github.com)
- 📦 **Fork this repository**: `TCA-InfraForge`

### 3️⃣ Your Computer
- 💻 **Any OS**: Windows, Mac, Linux
- 🔧 **Install Terraform**: [terraform.io/downloads](https://www.terraform.io/downloads)

---

## 🎬 Choose Your Path

<details>
<summary>🚀 <strong>QUICK DEPLOY</strong> - Get running in 10 minutes (Recommended)</summary>

Perfect for:
- ✅ Personal projects and learning
- ✅ Portfolio demonstrations  
- ✅ Small team collaboration

**Next Step:** [📱 Quick Deploy Guide →](#quick-deploy)

</details>

<details>
<summary>🏢 <strong>ENTERPRISE DEPLOY</strong> - Production-ready with advanced security</summary>

Perfect for:
- ✅ Company/team environments
- ✅ Colleague access required
- ✅ Compliance requirements

**Next Step:** [🏢 Enterprise Deploy Guide →](#enterprise-deploy)

</details>

<details>
<summary>🔧 <strong>CUSTOM DEPLOY</strong> - Advanced configuration options</summary>

Perfect for:
- ✅ Specific networking requirements
- ✅ Custom domain names
- ✅ SSO integration needed

**Next Step:** [🔧 Custom Deploy Guide →](#custom-deploy)

</details>

---

## 📱 Quick Deploy

**Perfect for getting started fast!**

<details>
<summary>Step 1: 🔑 Setup Oracle Cloud (3 minutes)</summary>

### 1️⃣ Create API Key
1. **Login** to [Oracle Cloud Console](https://cloud.oracle.com)
2. **Click** your profile icon (top right)

   ![Oracle Cloud Profile Menu](./docs/screenshots/oracle-cloud-profile-menu.png)
   *Click the profile icon in the top-right corner*

3. **Click** "User Settings"
4. **Click** "API Keys" (left menu)

   ![Oracle Cloud API Keys](./docs/screenshots/oracle-cloud-api-keys.png)
   *Navigate to API Keys section in the left sidebar*

5. **Click** "Add API Key"
6. **Select** "Generate API Key Pair"
7. **Click** "Download Private Key" → Save as `oci_api_key.pem`
8. **Click** "Add"
9. **Copy** the configuration (keep this window open!)

   ![Oracle Cloud API Configuration](./docs/screenshots/oracle-cloud-api-config.png)
   *Copy this configuration popup - you'll need it in Step 3*

### 2️⃣ Get Your Details
**Copy these from the configuration popup:**
- `tenancy_ocid` (starts with `ocid1.tenancy...`)
- `user_ocid` (starts with `ocid1.user...`) 
- `fingerprint` (format: `aa:bb:cc:dd...`)
- `region` (example: `us-ashburn-1`)

### 3️⃣ Find Your Compartment
1. **Menu** → "Identity & Security" → "Compartments"

   ![Oracle Cloud Compartments](./docs/screenshots/oracle-cloud-compartments.png)
   *Navigate to Compartments to find your root compartment OCID*

2. **Copy** the OCID of "root" compartment (starts with `ocid1.compartment...`)

**✅ Done!** Keep these details handy for Step 3.

</details>

<details>
<summary>Step 2: 🔐 Generate SSH Key (1 minute)</summary>

### On Mac/Linux:
```bash
# Create SSH key for secure access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/tca_infrastructure

# Just press Enter for all prompts (no passphrase needed)
```

### On Windows:
1. **Download** [PuTTY Key Generator](https://www.putty.org/)
2. **Click** "Generate"
3. **Save** private key as `tca_infrastructure.ppk`
4. **Copy** the public key text (starts with `ssh-rsa`)

**📝 Note the location** of your public key:
- Mac/Linux: `~/.ssh/tca_infrastructure.pub`
- Windows: Copy the public key text from PuTTY

**✅ Done!** Your keys are ready.

</details>

<details>
<summary>Step 3: 🛠️ Configure Deployment (2 minutes)</summary>

### 1️⃣ Download the Project
```bash
# Clone the repository
git clone https://github.com/temitayocharles/TCA-InfraForge.git
cd TCA-InfraForge/terraform/oracle-hybrid
```

### 2️⃣ Create Your Configuration
```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars
```

### 3️⃣ Get Your IP Address
```bash
# Find your current IP
curl ifconfig.me
```

![IP Address Lookup](./docs/screenshots/ip-address-lookup.png)
*Terminal showing your current public IP address*

**Copy this IP** - you'll need it next!

### 4️⃣ Edit Configuration File
**Open** `terraform.tfvars` in any text editor and **replace** these values:

```hcl
# Oracle Cloud Configuration (from Step 1)
tenancy_ocid     = "PASTE_YOUR_TENANCY_OCID_HERE"
user_ocid        = "PASTE_YOUR_USER_OCID_HERE" 
fingerprint      = "PASTE_YOUR_FINGERPRINT_HERE"
private_key_path = "/path/to/your/oci_api_key.pem"
compartment_id   = "PASTE_YOUR_COMPARTMENT_OCID_HERE"
region          = "PASTE_YOUR_REGION_HERE"

# SSH Configuration (from Step 2)
ssh_public_key_path = "/path/to/your/.ssh/tca_infrastructure.pub"

# GitHub Configuration  
github_token = "YOUR_GITHUB_TOKEN_HERE"
github_repo  = "yourusername/TCA-InfraForge"

# Security (your IP from above)
admin_ip_whitelist = ["YOUR.IP.HERE/32"]

# Contact Info
email = "your-email@example.com"
```

**✅ Done!** Your configuration is ready.

</details>

<details>
<summary>Step 4: 🚀 Deploy Platform (3 minutes)</summary>

### 1️⃣ Initialize Terraform
```bash
# Initialize the deployment system
terraform init
```

![Terraform Init Success](./docs/screenshots/terraform-init-success.png)
*Successful terraform initialization with provider downloads*

**Expected**: "Terraform has been successfully initialized!"

### 2️⃣ Preview Deployment
```bash
# See what will be created
terraform plan
```
**Expected**: Shows ~15 resources to be created

### 3️⃣ Deploy Everything
```bash
# Deploy your GitOps platform
terraform apply -auto-approve
```

**⏳ This takes 3-5 minutes...**

![Terraform Apply Success](./docs/screenshots/terraform-apply-success.png)
*Successful deployment showing all created resources and output URLs*

**Expected output:**
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
argocd_dashboard_url = "http://123.456.789.10:8080"
tca_dashboard_url = "http://123.456.789.20/"
```

**✅ Success!** Your platform is live!

</details>

<details>
<summary>Step 5: 🎉 Access Your Platform (30 seconds)</summary>

### 🎯 Your New URLs
**Copy these URLs from the terraform output:**

### ArgoCD Dashboard
- **URL**: `http://YOUR_VM1_IP:8080` 
- **Username**: `admin`
- **Password**: Check terraform output for auto-generated password

![ArgoCD Login Screen](./docs/screenshots/argocd-login-screen.png)
*ArgoCD login page - use admin and your generated password*

![ArgoCD Dashboard Overview](./docs/screenshots/argocd-dashboard-overview.png)
*ArgoCD main dashboard showing your GitOps applications*

### TCA Central Dashboard  
- **URL**: `http://YOUR_VM2_IP/`
- **Description**: Unified access to all services

![TCA Central Dashboard](./docs/screenshots/tca-central-dashboard.png)
*TCA unified dashboard providing access to all your GitOps tools*

### Grafana Monitoring
- **URL**: `http://YOUR_VM2_IP:3000`
- **Username**: `admin`  
- **Password**: Check terraform output for auto-generated password

**🎉 Congratulations!** You now have a professional GitOps platform!

</details>

**🎯 What's Next?**
- [📚 Learn ArgoCD Basics →](#argocd-basics)
- [🚀 Deploy Your First App →](#first-app)
- [📊 Setup Monitoring →](#monitoring-setup)

---

## 🏢 Enterprise Deploy

**For teams and production environments**

<details>
<summary>🔒 Enhanced Security Features</summary>

Enterprise deployment includes:

✅ **Auto-Generated 32-Character Passwords**  
✅ **IP Whitelisting for Admin Access**  
✅ **Automatic SSL Certificates**  
✅ **Bastion Host for Secure SSH**  
✅ **Comprehensive Audit Logging**  
✅ **Encrypted Backups**  
✅ **Security Event Monitoring**

**Configuration:**
```hcl
# Enable enterprise security
security_mode = "enterprise"
enable_enterprise_security = true

# Your office/team networks
admin_ip_whitelist = [
  "203.0.113.0/24",    # Office network
  "198.51.100.5/32",   # Your home IP
]

# SSL for professional URLs  
enable_automatic_ssl = true
domain_name = "infraforge.company.com"
ssl_email = "admin@company.com"
```

**Continue with:** [📱 Quick Deploy Steps →](#quick-deploy) (same process, enhanced security)

</details>

<details>
<summary>🏢 SSO Integration (Optional)</summary>

**Connect with company authentication:**

### Azure AD Integration
```hcl
enable_oidc_auth = true
oidc_issuer_url = "https://login.microsoftonline.com/YOUR-TENANT-ID/v2.0"
oidc_client_id = "your-azure-app-client-id" 
oidc_client_secret = "your-azure-app-client-secret"
```

### Google Workspace Integration  
```hcl
enable_oidc_auth = true
oidc_issuer_url = "https://accounts.google.com"
oidc_client_id = "your-google-client-id"
oidc_client_secret = "your-google-client-secret"  
```

**Setup Guide:** [🔗 SSO Configuration →](#sso-setup)

</details>

---

## 🔧 Custom Deploy

**Advanced configuration options**

<details>
<summary>🌐 Custom Domain Setup</summary>

### 1️⃣ Configure DNS
**Point your domain to the VM IPs:**
```
Type: A Record
Name: infraforge.company.com → VM1_IP
Name: monitoring.company.com → VM2_IP  
```

### 2️⃣ Update Configuration
```hcl
enable_automatic_ssl = true
domain_name = "infraforge.company.com"
ssl_email = "webmaster@company.com"
```

**Result:** Access via `https://infraforge.company.com` (SSL included!)

</details>

<details>
<summary>🔧 Resource Customization</summary>

### Adjust VM Sizes
```hcl
# Bigger ArgoCD VM (costs more)
argocd_vm_memory_gb = 4  # $2.40/month instead of $1.20
argocd_vm_ocpus = 2

# Keep support VM free
support_vm_memory_gb = 1  # Always Free
support_vm_ocpus = 1
```

### Network Customization
```hcl
vcn_cidr = "192.168.0.0/16"           # Custom network
public_subnet_cidr = "192.168.1.0/24" # Custom subnet
```

</details>

---

## 📚 Post-Deployment Guides

<details>
<summary>🎯 ArgoCD Basics</summary>

### First Login
1. **Open** ArgoCD URL from terraform output
2. **Username**: `admin`
3. **Password**: From terraform output (32 characters)
4. **Click** "Sign In"

### Deploy Your First App
1. **Click** "+ NEW APP" 

   ![ArgoCD New App Button](./docs/screenshots/argocd-new-app-button.png)
   *Click the "+ NEW APP" button to create your first application*

2. **Application Name**: `my-first-app`
3. **Project**: `default`
4. **Repository URL**: `https://github.com/argoproj/argocd-example-apps.git`
5. **Path**: `guestbook`
6. **Cluster**: `https://kubernetes.default.svc`
7. **Namespace**: `default`

   ![ArgoCD App Creation Form](./docs/screenshots/argocd-app-creation-form.png)
   *Fill out the application creation form with these values*

8. **Click** "CREATE"

   ![ArgoCD App Deployed](./docs/screenshots/argocd-app-deployed.png)
   *Your application successfully deployed and synced*

**🎉 Your first GitOps deployment!**

</details>

<details>
<summary>📊 Monitoring Setup</summary>

### Access Grafana
1. **Open** TCA Dashboard (VM2 URL)
2. **Click** "Monitoring" → "Grafana"
3. **Username**: `admin`
4. **Password**: From terraform output

### Pre-Built Dashboards
- **TCA Platform Overview**: System health and metrics
- **ArgoCD Applications**: GitOps deployment status  
- **Container Monitoring**: Docker performance metrics
- **Security Events**: Audit logs and alerts

**🎯 Everything configured automatically!**

</details>

<details>
<summary>🔧 Troubleshooting</summary>

### Can't Access ArgoCD?
```bash
# Check if services are running
ssh ubuntu@VM1_IP
docker ps

# Restart if needed  
docker-compose restart
```

### Forgot Passwords?
```bash
# View all auto-generated passwords
terraform output -json generated_credentials
```

### IP Access Blocked?
```bash
# Update your IP whitelist
# Edit terraform.tfvars:
admin_ip_whitelist = ["NEW.IP.HERE/32"]

# Apply changes
terraform apply -auto-approve
```

### Need Help?
- 🐛 **Issues**: [GitHub Issues](https://github.com/temitayocharles/TCA-InfraForge/issues)
- 📖 **Documentation**: [Full Docs](./README.md)
- 💬 **Community**: [Discussions](https://github.com/temitayocharles/TCA-InfraForge/discussions)

</details>

---

## ❓ FAQ

<details>
<summary>💰 What does this actually cost?</summary>

### Monthly Costs
- **VM1 (ArgoCD - 2GB)**: ~$1.20/month
- **VM2 (Monitoring - 1GB)**: $0 (Always Free)
- **Total**: ~$1.70/month

### Why Not Free?
ArgoCD needs 2GB RAM for stability. Oracle Always Free provides only 2GB total across ALL VMs. We use 1GB for Always Free monitoring + 1.20 for 2GB ArgoCD VM.

### Compared to Alternatives
- **AWS EKS**: ~$70/month
- **Google GKE**: ~$65/month  
- **TCA-InfraForge**: ~$1.70/month
- **Savings**: 97% cost reduction!

</details>

<details>
<summary>🔒 Is this secure for production?</summary>

### Enterprise Security Features
✅ **Auto-generated 32-char passwords**  
✅ **IP-based access restrictions**  
✅ **SSH key authentication only**  
✅ **Automatic SSL certificates**  
✅ **Comprehensive audit logging**  
✅ **Encrypted backups**  
✅ **Container resource limits**  
✅ **Security event monitoring**

### Used By
- ✅ Development teams
- ✅ Small-medium businesses  
- ✅ Portfolio demonstrations
- ✅ Learning environments

**Yes, it's production-ready with enterprise security!**

</details>

<details>
<summary>🚀 What can I deploy with this?</summary>

### Perfect For
- 🌐 **Web Applications**: React, Vue, Angular apps
- 🔧 **Microservices**: Node.js, Python, Go services  
- 📊 **Databases**: PostgreSQL, MySQL, MongoDB
- 🤖 **ML/AI Workloads**: TensorFlow, PyTorch models
- 📱 **Mobile Backends**: REST APIs, GraphQL
- 🛠️ **DevOps Tools**: Jenkins, SonarQube, etc.

### Real Examples  
- E-commerce platforms
- Portfolio websites  
- API backends
- Data processing pipelines
- ML model serving
- Team collaboration tools

**Anything that runs in containers!**

</details>

---

## 🎯 Next Steps

**Choose your journey:**

### 🚀 **Just Getting Started?**
[📱 Quick Deploy Guide →](#quick-deploy) - Get running in 10 minutes

### 🏢 **For Your Team/Company?**  
[🏢 Enterprise Deploy Guide →](#enterprise-deploy) - Production-ready security

### 🎓 **Want to Learn More?**
[📚 Complete Documentation →](./README.md) - Deep dive into GitOps

### 💼 **Building Your Portfolio?**
[🎯 Portfolio Guide →](#portfolio-guide) - Showcase your skills

---

**Built with ❤️ by the TCA-InfraForge Community**  
**⭐ Star us on GitHub if this helped you!**