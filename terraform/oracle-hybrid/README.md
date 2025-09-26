# TCA-InfraForge Hybrid Oracle Cloud Deployment Guide
# Professional GitOps Platform with ArgoCD GUI - $1.70/month

## 🚀 Architecture Overview

This hybrid deployment combines:
- **GitHub Actions**: CI/CD pipeline (existing)
- **Oracle Cloud PAYG**: Persistent infrastructure (~$1.70/month)
- **ArgoCD**: Professional GitOps with GUI (2GB RAM)
- **24/7 Access**: Remote persistent platform

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────┐
│                    TCA-InfraForge Hybrid                   │
├─────────────────────┬───────────────────────────────────────┤
│ VM1 (2GB - $1.20/m) │ VM2 (1GB - Free)                     │
├─────────────────────┼───────────────────────────────────────┤
│ • ArgoCD Server     │ • Prometheus Monitoring              │
│ • Gitea Git Server  │ • Grafana Dashboards                 │
│ • GitHub Webhooks   │ • Uptime Kuma                        │
│ • Caddy Proxy       │ • Nginx Load Balancer                │
│ • Docker Stack     │ • TCA Dashboard                       │
└─────────────────────┴───────────────────────────────────────┘
```

## 💰 Cost Analysis

| Component | Specs | Monthly Cost | Purpose |
|-----------|--------|-------------|---------|
| VM1 | 2GB RAM, 1 OCPU | ~$1.20 | ArgoCD + Core GitOps |
| VM2 | 1GB RAM, 1 OCPU | $0 (Free) | Monitoring + Support |
| **Total** | **3GB RAM, 2 VMs** | **~$1.70** | **Professional Platform** |

### ROI Analysis
- **Investment**: $1.70/month (~$20/year)
- **Value**: Professional GitOps platform, 24/7 access, portfolio demonstration
- **Alternative**: AWS EKS (~$70/month), GKE (~$65/month)
- **Savings**: 97% cost reduction vs managed Kubernetes

## 📋 Pre-Deployment Checklist

### 1. Oracle Cloud Account Setup
```bash
# Ensure you have:
✅ Oracle Cloud account with PAYG enabled
✅ API key configured for Terraform
✅ Appropriate tenancy/compartment permissions
✅ SSH key pair generated
```

### 2. GitHub Integration Ready
```bash
# Ensure you have:
✅ GitHub repository: TCA-InfraForge
✅ GitHub token for webhooks
✅ Existing GitHub Actions workflow
✅ ArgoCD applications in repo
```

### 3. Local Environment
```bash
# Required tools:
✅ Terraform >= 1.0
✅ Oracle Cloud CLI (optional)
✅ SSH client
✅ Git
```

## 🛠️ Deployment Instructions

### Step 1: Configure Terraform Variables

Create `terraform.tfvars`:
```hcl
# terraform.tfvars
tenancy_ocid     = "ocid1.tenancy.oc1..your-tenancy-id"
user_ocid        = "ocid1.user.oc1..your-user-id"
fingerprint      = "aa:bb:cc:dd:ee:ff:gg:hh:ii:jj:kk:ll:mm:nn:oo:pp"
private_key_path = "/Users/charlie/.oci/oci_api_key.pem"
compartment_id   = "ocid1.compartment.oc1..your-compartment-id"
region          = "us-ashburn-1"

# SSH Configuration
ssh_public_key_path = "/Users/charlie/.ssh/id_rsa.pub"

# GitHub Integration
github_token = "ghp_your_github_personal_access_token"
github_repo  = "temitayocharles/TCA-InfraForge"

# Email for notifications
email = "your-email@example.com"

# Environment
environment = "hybrid-prod"
```

### Step 2: Initialize and Deploy

```bash
cd /Users/charlie/Documents/TCA-InfraForge/terraform/oracle-hybrid

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply -auto-approve
```

### Step 3: Post-Deployment Configuration

```bash
# Get outputs
terraform output

# Example outputs:
# argocd_vm_public_ip = "192.0.2.100"
# support_vm_public_ip = "192.0.2.101"
# argocd_dashboard_url = "http://192.0.2.100:8080"
# tca_dashboard_url = "http://192.0.2.101/"
```

### Step 4: Verify Services

```bash
# Check ArgoCD (VM1)
curl -I http://VM1_IP:8080/healthz

# Check TCA Dashboard (VM2)  
curl -I http://VM2_IP/

# SSH to VMs for detailed inspection
ssh ubuntu@VM1_IP
ssh ubuntu@VM2_IP
```

## 🔧 GitHub Actions Integration

### Update Existing Workflow

Modify `.github/workflows/deploy.yml`:

```yaml
name: TCA-InfraForge Hybrid Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy-to-oracle:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Trigger Oracle Cloud Deployment
        run: |
          # Send webhook to Oracle Cloud
          curl -X POST \
            -H "Content-Type: application/json" \
            -H "X-Hub-Signature: sha1=$(echo -n '${{ github.event.head_commit.id }}' | openssl dgst -sha1 -hmac '${{ secrets.WEBHOOK_SECRET }}' | cut -d' ' -f2)" \
            -d '{"ref":"refs/heads/main","head_commit":{"id":"${{ github.sha }}"}}' \
            http://${{ secrets.ORACLE_VM1_IP }}:9000/hooks/tca-deploy-hook
            
      - name: Wait for ArgoCD Sync
        run: |
          echo "⏳ Waiting for ArgoCD to sync applications..."
          sleep 60
          
          # Check ArgoCD health
          curl -f http://${{ secrets.ORACLE_VM1_IP }}:8080/healthz || exit 1
          echo "✅ ArgoCD is healthy"
          
      - name: Deployment Summary
        run: |
          echo "🚀 TCA-InfraForge Hybrid Deployment Complete!"
          echo "📊 ArgoCD Dashboard: http://${{ secrets.ORACLE_VM1_IP }}:8080"
          echo "🎯 TCA Dashboard: http://${{ secrets.ORACLE_VM2_IP }}/"
          echo "💰 Monthly Cost: ~$1.70"
```

### Add GitHub Secrets

```bash
# In GitHub repository settings > Secrets, add:
WEBHOOK_SECRET=your-webhook-secret-token
ORACLE_VM1_IP=your-vm1-public-ip
ORACLE_VM2_IP=your-vm2-public-ip
```

## 📊 Service Access Guide

### ArgoCD Dashboard (VM1)
```bash
# URL: http://VM1_IP:8080
# Default credentials:
Username: admin
Password: # Get from VM1
ssh ubuntu@VM1_IP
cat /home/ubuntu/argocd-initial-password.txt
```

### TCA Central Dashboard (VM2)
```bash
# URL: http://VM2_IP/
# Provides unified access to all services
Services available:
- ArgoCD (/argocd/)
- Gitea (/gitea/)  
- Monitoring (/monitoring/)
- Prometheus (/prometheus/)
- Uptime Monitoring (/uptime/)
```

### Grafana Monitoring
```bash
# URL: http://VM2_IP:3000
Username: admin
Password: tca-hybrid-2024
```

## 🔍 Monitoring and Maintenance

### Resource Monitoring

```bash
# VM1 (ArgoCD) monitoring
ssh ubuntu@VM1_IP
tail -f /var/log/tca-hybrid-monitor.log

# VM2 (Support) monitoring  
ssh ubuntu@VM2_IP
tail -f /var/log/tca-support-monitor.log
```

### Container Health Checks

```bash
# Check all containers
docker ps -a

# Check specific service logs
docker logs argocd-server
docker logs gitea
docker logs prometheus
docker logs grafana
```

### System Resource Usage

```bash
# Memory usage
free -h

# Docker stats
docker stats --no-stream

# System load
htop
```

## 🛡️ Security Considerations

### Network Security
- Oracle Cloud Security Groups configured for specific ports
- Internal service communication on private network
- Public access only to necessary web interfaces

### Container Security
- Memory limits on all containers
- Resource constraints to prevent OOM
- Regular container updates via Watchtower

### Access Control
- SSH key-based authentication only
- ArgoCD RBAC (configure post-deployment)
- Grafana user management

## 🔧 Troubleshooting Guide

### Common Issues

#### 1. ArgoCD OOM (Out of Memory)
```bash
# Check memory usage
ssh ubuntu@VM1_IP
free -h
docker stats argocd-controller

# Solution: Restart with memory optimization
cd /home/ubuntu
docker-compose restart argocd-application-controller
```

#### 2. GitHub Webhook Issues
```bash
# Check webhook logs
ssh ubuntu@VM1_IP
docker logs webhook-receiver

# Test webhook manually
curl -X POST http://VM1_IP:9000/hooks/tca-deploy-hook \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

#### 3. Service Discovery Issues
```bash
# Check container network
docker network ls
docker network inspect ubuntu_tca-hybrid

# Restart networking
docker-compose down && docker-compose up -d
```

## 🚀 Scaling and Upgrades

### Adding More Applications
1. Add ArgoCD Application manifests to GitHub repo
2. Webhook automatically triggers deployment
3. ArgoCD syncs new applications

### VM Resource Scaling
```bash
# Scale VM1 (if needed)
# Oracle Cloud Console > Compute > Edit Instance
# Change to VM.Standard.E2.2.Micro (4GB) for +$1.20/month

# Scale VM2 (Always Free limits)
# Cannot scale beyond 1GB on Always Free
```

### Container Updates
```bash
# Automatic via Watchtower (daily at 2 AM)
# Manual update:
cd /home/ubuntu
docker-compose pull
docker-compose up -d
```

## 📈 Success Metrics

### Performance Targets
- **ArgoCD Response Time**: < 2 seconds
- **Sync Time**: < 30 seconds for typical apps
- **Uptime**: > 99.5% (monitored by Uptime Kuma)
- **Memory Usage**: < 80% on both VMs

### Cost Efficiency
- **Monthly Cost**: ~$1.70 (target: < $2)
- **Cost per GB RAM**: $0.57 (vs AWS: $8+)
- **Platform Value**: Professional GitOps for coffee money

## 🎯 Next Steps

### Immediate (Post-Deployment)
1. ✅ Access ArgoCD dashboard and change admin password
2. ✅ Configure GitHub webhook integration
3. ✅ Deploy first application via ArgoCD
4. ✅ Set up Grafana dashboards
5. ✅ Configure Uptime Kuma monitoring

### Short Term (Week 1)
1. 📊 Add custom Grafana dashboards for ArgoCD metrics
2. 🔒 Configure ArgoCD RBAC and user management  
3. 📧 Set up email notifications for critical alerts
4. 🏗️ Add more applications to the GitOps workflow
5. 📝 Document application deployment patterns

### Long Term (Month 1)
1. 🔐 Implement SSL/TLS certificates
2. 🌐 Configure custom domain names
3. 🏃‍♂️ Optimize resource usage and scaling policies
4. 📊 Advanced monitoring with custom metrics
5. 🎯 Portfolio demonstrations and documentation

---

## 🎉 Congratulations!

You now have a **professional GitOps platform** running on Oracle Cloud for less than $2/month!

**Key Benefits Achieved:**
- ✅ 24/7 persistent ArgoCD GUI access
- ✅ Professional portfolio demonstration platform
- ✅ 97% cost savings vs managed Kubernetes
- ✅ Hybrid CI/CD with GitHub Actions + Oracle Cloud
- ✅ Comprehensive monitoring and alerting
- ✅ Scalable architecture for growth

**Professional Value:**
- 🎯 Real-world GitOps experience with ArgoCD
- 🏗️ Infrastructure as Code with Terraform
- 🌐 Cloud-native application deployment
- 📊 Production monitoring and observability
- 💼 Portfolio-ready professional platform

**Your $1.70/month investment** has created a platform worth **thousands in professional development value**!

---

*TCA-InfraForge Hybrid v2.0 - Where Professional meets Affordable* ⚡