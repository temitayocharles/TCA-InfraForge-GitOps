# TCA-InfraForge Enterprise Security Variables
# Production-grade security configuration

# Security Hardening Variables
variable "enable_enterprise_security" {
  description = "Enable enterprise-grade security features"
  type        = bool
  default     = true
}

variable "security_mode" {
  description = "Security mode: development, production, enterprise"
  type        = string
  default     = "enterprise"
  
  validation {
    condition = contains(["development", "production", "enterprise"], var.security_mode)
    error_message = "Security mode must be development, production, or enterprise."
  }
}

# Network Security
variable "admin_ip_whitelist" {
  description = "List of IP addresses/CIDRs allowed admin access (SSH, admin UIs)"
  type        = list(string)
  default     = []  # MUST be configured for production
  
  validation {
    condition = var.security_mode == "development" || length(var.admin_ip_whitelist) > 0
    error_message = "Admin IP whitelist must be configured for production/enterprise security modes."
  }
}

variable "enable_bastion_host" {
  description = "Create bastion host for secure SSH access"
  type        = bool
  default     = true  # Enterprise default
}

variable "enable_vpn_gateway" {
  description = "Enable Oracle Cloud VPN gateway for site-to-site connectivity"
  type        = bool
  default     = false
}

# SSL/TLS Configuration
variable "enable_automatic_ssl" {
  description = "Enable automatic SSL certificate generation via Let's Encrypt"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for SSL certificates (e.g., infraforge.company.com)"
  type        = string
  default     = ""
}

variable "ssl_email" {
  description = "Email for Let's Encrypt certificate notifications"
  type        = string
  default     = ""
}

# Authentication & Authorization
variable "enable_oidc_auth" {
  description = "Enable OIDC authentication for ArgoCD and Grafana"
  type        = bool
  default     = false
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL (e.g., Azure AD, Google, Okta)"
  type        = string
  default     = ""
}

variable "oidc_client_id" {
  description = "OIDC client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "oidc_client_secret" {
  description = "OIDC client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# Password Security
variable "auto_generate_passwords" {
  description = "Automatically generate secure passwords for all services"
  type        = bool
  default     = true
}

variable "password_length" {
  description = "Length of auto-generated passwords"
  type        = number
  default     = 32
}

# Monitoring & Alerting Security
variable "enable_security_monitoring" {
  description = "Enable security event monitoring and alerting"
  type        = bool
  default     = true
}

variable "security_alert_webhook" {
  description = "Webhook URL for security alerts (Slack, Teams, etc.)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

# Backup & Recovery Security
variable "enable_encrypted_backups" {
  description = "Enable encrypted backups to Oracle Object Storage"
  type        = bool
  default     = true
}

variable "backup_encryption_key" {
  description = "Encryption key for backups (leave empty for auto-generation)"
  type        = string
  default     = ""
  sensitive   = true
}

# Container Security
variable "enable_container_scanning" {
  description = "Enable container vulnerability scanning"
  type        = bool
  default     = true
}

variable "allowed_registries" {
  description = "List of allowed container registries"
  type        = list(string)
  default = [
    "docker.io",
    "quay.io", 
    "gcr.io",
    "ghcr.io",
    "registry.k8s.io"
  ]
}

# Compliance & Governance
variable "enable_compliance_scanning" {
  description = "Enable compliance scanning (CIS, SOC2, etc.)"
  type        = bool
  default     = false
}

variable "compliance_frameworks" {
  description = "Compliance frameworks to scan for"
  type        = list(string)
  default     = ["cis", "nist"]
}

# Resource Protection
variable "enable_resource_quotas" {
  description = "Enable strict resource quotas to prevent abuse"
  type        = bool
  default     = true
}

variable "max_cpu_per_container" {
  description = "Maximum CPU per container (millicores)"
  type        = number
  default     = 1000  # 1 CPU core
}

variable "max_memory_per_container" {
  description = "Maximum memory per container (MB)"
  type        = number
  default     = 512
}

# Local Resource Limits for Enterprise Security
locals {
  # Security-based memory allocations (stricter than performance-based)
  enterprise_memory_limits = {
    argocd_server     = var.security_mode == "enterprise" ? "256m" : "300m"
    argocd_controller = var.security_mode == "enterprise" ? "512m" : "600m" 
    argocd_repo       = var.security_mode == "enterprise" ? "256m" : "300m"
    gitea            = var.security_mode == "enterprise" ? "128m" : "200m"
    prometheus       = var.security_mode == "enterprise" ? "128m" : "200m"
    grafana          = var.security_mode == "enterprise" ? "96m"  : "150m"
  }
  
  # Admin access restrictions
  admin_cidrs = var.security_mode == "development" ? ["0.0.0.0/0"] : var.admin_ip_whitelist
  
  # Service exposure based on security mode
  expose_direct_ports = var.security_mode == "development"
  
  # Generated secure passwords
  use_secure_passwords = var.auto_generate_passwords && var.security_mode != "development"
}

# Password Generation Resources
resource "random_password" "argocd_admin" {
  count   = local.use_secure_passwords ? 1 : 0
  length  = var.password_length
  special = true
}

resource "random_password" "gitea_admin" {
  count   = local.use_secure_passwords ? 1 : 0  
  length  = var.password_length
  special = true
}

resource "random_password" "grafana_admin" {
  count   = local.use_secure_passwords ? 1 : 0
  length  = var.password_length  
  special = true
}

resource "random_password" "backup_encryption" {
  count   = var.enable_encrypted_backups && var.backup_encryption_key == "" ? 1 : 0
  length  = 64
  special = false  # Avoid special chars in encryption keys
}

# Security Monitoring Configuration
locals {
  security_config = {
    enable_enterprise_security = var.enable_enterprise_security
    security_mode             = var.security_mode
    admin_ip_whitelist       = local.admin_cidrs
    enable_bastion_host      = var.enable_bastion_host
    enable_automatic_ssl     = var.enable_automatic_ssl
    domain_name              = var.domain_name
    enable_oidc_auth         = var.enable_oidc_auth
    enable_security_monitoring = var.enable_security_monitoring
    enable_audit_logging     = var.enable_audit_logging
    enable_encrypted_backups = var.enable_encrypted_backups
    
    # Generated passwords (only output hashes for security)
    passwords_generated = local.use_secure_passwords
    
    # Compliance settings
    enable_compliance_scanning = var.enable_compliance_scanning
    compliance_frameworks     = var.compliance_frameworks
    
    # Resource limits
    memory_limits = local.enterprise_memory_limits
    max_cpu_per_container = var.max_cpu_per_container
    max_memory_per_container = var.max_memory_per_container
  }
}

# Export security configuration for cloud-init templates
output "security_configuration" {
  description = "Security configuration for cloud-init"
  value = local.security_config
  sensitive = false  # No sensitive data in output
}

# Export generated passwords securely (for terraform state only)
output "generated_credentials" {
  description = "Generated service credentials (stored in terraform state)"
  value = {
    argocd_password  = local.use_secure_passwords ? random_password.argocd_admin[0].result : "development-password"
    gitea_password   = local.use_secure_passwords ? random_password.gitea_admin[0].result : "development-password"  
    grafana_password = local.use_secure_passwords ? random_password.grafana_admin[0].result : "development-password"
    backup_key       = var.enable_encrypted_backups ? (var.backup_encryption_key != "" ? var.backup_encryption_key : random_password.backup_encryption[0].result) : ""
  }
  sensitive = true  # Mark as sensitive - only visible in terraform state
}