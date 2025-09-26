# TCA-InfraForge Hybrid: Terraform Configuration Variables

# Oracle Cloud Provider Configuration
variable "tenancy_ocid" {
  description = "The OCID of your Oracle Cloud tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of your Oracle Cloud user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of your Oracle Cloud API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to your Oracle Cloud private key file"
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment to create resources in"
  type        = string
}

variable "region" {
  description = "The Oracle Cloud region to deploy to"
  type        = string
  default     = "us-ashburn-1"
}

# Networking Configuration
variable "vcn_cidr" {
  description = "CIDR block for the Virtual Cloud Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string  
  default     = "10.0.1.0/24"
}

# SSH Configuration
variable "ssh_public_key_path" {
  description = "Path to your SSH public key file"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content (alternative to file path)"
  type        = string
  default     = ""
}

# VM Configuration
variable "argocd_vm_shape" {
  description = "Shape for the ArgoCD VM (2GB RAM)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "argocd_vm_memory_gb" {
  description = "Memory in GB for ArgoCD VM"
  type        = number
  default     = 2
}

variable "argocd_vm_ocpus" {
  description = "OCPUs for ArgoCD VM"
  type        = number
  default     = 1
}

variable "support_vm_shape" {
  description = "Shape for the Support VM (1GB RAM - Always Free)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "support_vm_memory_gb" {
  description = "Memory in GB for Support VM (Always Free: max 1GB)"
  type        = number
  default     = 1
}

variable "support_vm_ocpus" {
  description = "OCPUs for Support VM"
  type        = number
  default     = 1
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GB (Always Free: max 50GB)"
  type        = number
  default     = 50
}

# Operating System Configuration
variable "os_image_id" {
  description = "OCID of the OS image (leave empty for latest Ubuntu)"
  type        = string
  default     = ""
}

variable "os_name" {
  description = "Operating system name"
  type        = string
  default     = "Canonical Ubuntu"
}

variable "os_version" {
  description = "Operating system version"
  type        = string
  default     = "22.04"
}

# GitHub Integration
variable "github_token" {
  description = "GitHub personal access token for webhook authentication"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = "temitayocharles/TCA-InfraForge"
}

variable "github_webhook_secret" {
  description = "Secret for GitHub webhook authentication"
  type        = string
  default     = "tca-hybrid-webhook-secret-2024"
  sensitive   = true
}

# Email Configuration
variable "email" {
  description = "Email address for notifications and monitoring alerts"
  type        = string
  default     = "admin@tca-infraforge.com"
}

# Project Configuration
variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "tca-infraforge"
}

variable "environment" {
  description = "Environment name (dev, staging, prod, hybrid-prod)"
  type        = string
  default     = "hybrid-prod"
}

# Availability Domain Configuration
variable "availability_domain" {
  description = "Availability domain for resources (leave empty for automatic)"
  type        = string
  default     = ""
}

# Load Balancer Configuration
variable "load_balancer_shape" {
  description = "Load balancer shape (flexible allows custom sizing)"
  type        = string
  default     = "flexible"
}

variable "load_balancer_min_bandwidth_mbps" {
  description = "Minimum bandwidth for flexible load balancer"
  type        = number
  default     = 10
}

variable "load_balancer_max_bandwidth_mbps" {
  description = "Maximum bandwidth for flexible load balancer"
  type        = number
  default     = 100
}

# Security Configuration
variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Warning: This allows SSH from anywhere
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "List of CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable Oracle Cloud monitoring for resources"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable Oracle Cloud logging for resources"
  type        = bool
  default     = true
}

# Cost Management
variable "enable_cost_tracking" {
  description = "Enable cost tracking tags on all resources"
  type        = bool
  default     = true
}

variable "cost_center" {
  description = "Cost center for billing and tracking"
  type        = string
  default     = "tca-infraforge-hybrid"
}

# ArgoCD Configuration
variable "argocd_admin_password" {
  description = "Custom admin password for ArgoCD (leave empty for auto-generated)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_server_replicas" {
  description = "Number of ArgoCD server replicas (1 for 2GB system)"
  type        = number
  default     = 1
}

# Gitea Configuration
variable "gitea_admin_user" {
  description = "Gitea administrator username"
  type        = string
  default     = "admin"
}

variable "gitea_admin_password" {
  description = "Gitea administrator password"
  type        = string
  default     = "tca-hybrid-2024"
  sensitive   = true
}

variable "gitea_admin_email" {
  description = "Gitea administrator email"
  type        = string
  default     = "admin@tca-infraforge.com"
}

# Backup Configuration
variable "enable_backups" {
  description = "Enable automatic backups for persistent data"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Development/Debug Configuration
variable "enable_debug_logging" {
  description = "Enable debug logging for troubleshooting"
  type        = bool
  default     = false
}

variable "create_bastion_host" {
  description = "Create a bastion host for secure SSH access"
  type        = bool
  default     = false
}

# Resource Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    "Project"     = "TCA-InfraForge"
    "Environment" = "Hybrid"
    "Platform"    = "GitOps"
    "ManagedBy"   = "Terraform"
    "Owner"       = "TCA"
  }
}

# Validation Rules
locals {
  # Validate GitHub repository format
  github_repo_parts = split("/", var.github_repo)
  is_valid_github_repo = length(local.github_repo_parts) == 2
  
  # Validate email format (basic)
  is_valid_email = can(regex("^[\\w\\.-]+@[\\w\\.-]+\\.[a-zA-Z]{2,}$", var.email))
  
  # Validate memory constraints for Always Free
  is_support_vm_always_free = var.support_vm_memory_gb <= 1 && var.support_vm_ocpus <= 1
  
  # Calculate estimated monthly cost
  argocd_vm_cost_monthly = var.argocd_vm_memory_gb * 0.60  # Approximate $0.60/GB/month
  support_vm_cost_monthly = var.support_vm_memory_gb <= 1 ? 0 : var.support_vm_memory_gb * 0.60
  estimated_monthly_cost = local.argocd_vm_cost_monthly + local.support_vm_cost_monthly
}

# Validation
variable "validate_configuration" {
  description = "Enable configuration validation"
  type        = bool
  default     = true
  
  validation {
    condition     = !var.validate_configuration || local.is_valid_github_repo
    error_message = "GitHub repository must be in format 'owner/repo'."
  }
  
  validation {
    condition     = !var.validate_configuration || local.is_valid_email
    error_message = "Email must be a valid email address format."
  }
  
  validation {
    condition     = !var.validate_configuration || var.argocd_vm_memory_gb >= 2
    error_message = "ArgoCD VM requires at least 2GB RAM for stable operation."
  }
  
  validation {
    condition     = !var.validate_configuration || local.is_support_vm_always_free
    error_message = "Support VM must use Always Free specs (≤1GB RAM, ≤1 OCPU) to avoid charges."
  }
  
  validation {
    condition     = !var.validate_configuration || var.boot_volume_size_gb <= 50
    error_message = "Boot volume size must be ≤50GB for Always Free eligibility."
  }
}

# Output estimated cost for user awareness (defined in main.tf outputs)