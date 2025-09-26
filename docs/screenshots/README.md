# Screenshot Generation Guide for TCA-InfraForge Documentation

## Required Screenshots for Enhanced Documentation

### 🔑 Oracle Cloud Setup Screenshots
1. **oracle-cloud-api-keys.png** - Oracle Cloud Console showing API Keys section
2. **oracle-cloud-compartments.png** - Compartments page with root compartment highlighted
3. **oracle-cloud-user-settings.png** - User profile menu with "User Settings" option

### 🚀 ArgoCD Interface Screenshots  
4. **argocd-login-screen.png** - ArgoCD login page with username/password fields
5. **argocd-dashboard-overview.png** - Main ArgoCD dashboard showing applications
6. **argocd-new-app-button.png** - ArgoCD dashboard highlighting "+ NEW APP" button
7. **argocd-app-creation-form.png** - Application creation form with all fields
8. **argocd-app-deployed.png** - Successful application deployment view

### 📊 Monitoring & Dashboards Screenshots
9. **tca-central-dashboard.png** - TCA unified dashboard showing all services
10. **grafana-login.png** - Grafana login screen with credentials
11. **grafana-dashboard-overview.png** - Main Grafana dashboard with metrics
12. **prometheus-targets.png** - Prometheus targets page showing service discovery

### 🛡️ Security Screenshots  
13. **terraform-output-passwords.png** - Terminal showing generated secure passwords
14. **ssh-key-generation.png** - Terminal showing SSH key generation process
15. **ip-address-lookup.png** - Terminal showing curl ifconfig.me result

### 🔧 Terraform Deployment Screenshots
16. **terraform-init-success.png** - Terminal showing terraform init completion
17. **terraform-plan-output.png** - Terraform plan showing resources to be created
18. **terraform-apply-success.png** - Successful terraform apply with outputs
19. **terraform-outputs-display.png** - terraform output command showing URLs and credentials

### 📱 Mobile-Responsive Views
20. **mobile-tca-dashboard.png** - TCA dashboard on mobile device
21. **mobile-argocd-view.png** - ArgoCD interface on mobile

### 🏢 Enterprise Security Views  
22. **security-audit-logs.png** - Security audit log entries
23. **bastion-host-connection.png** - SSH connection through bastion host
24. **ssl-certificate-valid.png** - Browser showing valid SSL certificate

## Screenshot Specifications

### Technical Requirements
- **Resolution**: 1920x1080 minimum for desktop screenshots
- **Format**: PNG with transparency where applicable
- **Compression**: Optimized for web (< 500KB each)
- **Mobile**: 375x812 (iPhone 13 Pro dimensions)

### Content Requirements
- **Annotations**: Red arrows pointing to important elements
- **Highlights**: Yellow boxes around key areas
- **Blur sensitive data**: OCIDs, IPs, passwords
- **Include browser chrome**: Show full browser window for web UIs
- **Terminal screenshots**: Include prompt and command history

### Annotation Style Guide
- **Arrows**: Red, 3px width, pointing to clickable elements
- **Boxes**: Yellow, 2px border, 20% opacity fill for highlighting
- **Text callouts**: White background, black text, 14px font
- **Numbering**: Blue circles with white numbers for step sequences

## Screenshot Generation Commands

### For Documentation Authors
```bash
# Create screenshots directory structure
mkdir -p docs/screenshots/{oracle-cloud,argocd,monitoring,security,terraform,mobile}

# Screenshot naming convention
{category}-{description}-{step-number}.png

# Examples:
oracle-cloud-api-keys-step-1.png
argocd-dashboard-overview.png  
terraform-apply-success.png
```

### Browser Screenshot Extensions
- **Full Page Screen Capture** (Chrome)
- **Firefox Screenshot** (Built-in F12 tools)
- **Lightshot** (Cross-platform)

### Terminal Screenshot Tools
- **macOS**: Cmd+Shift+4, then drag to select terminal area
- **Linux**: `gnome-screenshot -a` or `scrot -s`
- **Windows**: Windows Key + Shift + S

## Image Optimization
```bash
# Install optimization tools
npm install -g imagemin-cli imagemin-pngquant

# Optimize all screenshots
imagemin docs/screenshots/*.png --out-dir=docs/screenshots/optimized --plugin=pngquant

# Or use online tools:
# - TinyPNG.com
# - Squoosh.app
# - Kraken.io
```

## Embedding in Documentation

### Markdown Syntax
```markdown
![Screenshot Description](./docs/screenshots/screenshot-name.png)

<!-- With size control -->
<img src="./docs/screenshots/screenshot-name.png" alt="Description" width="600">

<!-- With caption -->
![Oracle Cloud API Keys](./docs/screenshots/oracle-cloud-api-keys.png)
*Figure 1: Oracle Cloud Console - Navigating to API Keys section*
```

### Accessibility
- **Alt text**: Descriptive alternative text for screen readers
- **Captions**: Explain what the screenshot shows
- **High contrast**: Ensure annotations are visible
- **Responsive**: Images scale on mobile devices

## Quality Checklist

### Before Adding Screenshots
- [ ] Image is clear and readable at 50% zoom
- [ ] Sensitive information is blurred or masked
- [ ] Annotations clearly point to relevant elements
- [ ] File size is optimized (< 500KB)
- [ ] Alt text is descriptive and helpful
- [ ] Caption explains the context and next steps

### Content Verification  
- [ ] Screenshot matches current UI (not outdated)
- [ ] All mentioned elements are visible in screenshot
- [ ] Step numbers match documentation sequence
- [ ] Browser/terminal shows realistic content
- [ ] Mobile screenshots test responsive design

## Maintenance Schedule

### Regular Updates
- **Monthly**: Check for UI changes in Oracle Cloud Console
- **Quarterly**: Verify ArgoCD interface screenshots
- **After major updates**: Re-capture all affected screenshots
- **User feedback**: Update based on documentation issues

### Version Control
```bash
# Track screenshot changes
git add docs/screenshots/
git commit -m "📸 Update screenshots for v2.1 interface changes"

# Tag screenshot versions
git tag -a screenshots-v2.1 -m "Screenshot set for documentation v2.1"
```

---

**Note**: This guide ensures consistent, professional screenshots that enhance user understanding and reduce support queries.