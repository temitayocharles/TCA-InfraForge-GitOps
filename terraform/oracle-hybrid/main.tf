# 🚀 TCA-InfraForge: Hybrid GitHub Actions + Oracle Cloud Architecture
# Professional GitOps platform with persistent infrastructure

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Variables for Oracle Cloud PAYG configuration
variable "tenancy_ocid" {
  description = "The OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of your user"
  type        = string
}

variable "private_key_path" {
  description = "Path to your private key file"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of your key"
  type        = string
}

variable "region" {
  description = "Your home region"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "The OCID of your compartment"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token for webhook setup"
  type        = string
  sensitive   = true
}

# Provider configuration
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region          = var.region
}

# Get availability domain
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Create VCN for TCA-InfraForge
resource "oci_core_vcn" "tca_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "tca-hybrid-vcn"
  cidr_block     = "10.0.0.0/16"
  
  freeform_tags = {
    "Project" = "TCA-InfraForge-Hybrid"
    "Environment" = "Production"
    "Owner" = "Temitayo-Charles-Akinniranye"
    "Architecture" = "GitHub-Actions-Oracle-Hybrid"
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "tca_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tca_vcn.id
  display_name   = "tca-hybrid-igw"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "tca_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tca_vcn.id
  display_name   = "tca-hybrid-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.tca_igw.id
  }
}

# Security List - Professional hybrid configuration
resource "oci_core_security_list" "tca_seclist" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tca_vcn.id
  display_name   = "tca-hybrid-seclist"

  # Outbound rules
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Inbound rules
  # SSH
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # ArgoCD UI
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8080
      max = 8080
    }
  }

  # Gitea
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 3000
      max = 3000
    }
  }

  # Grafana
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 3001
      max = 3001
    }
  }

  # GitHub Webhook port
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 9000
      max = 9000
    }
  }

  # Internal communication
  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/16"
  }
}

# Subnet for TCA-InfraForge
resource "oci_core_subnet" "tca_subnet" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.tca_vcn.id
  cidr_block          = "10.0.1.0/24"
  display_name        = "tca-hybrid-subnet"
  route_table_id      = oci_core_route_table.tca_rt.id
  security_list_ids   = [oci_core_security_list.tca_seclist.id]
  dhcp_options_id     = oci_core_vcn.tca_vcn.default_dhcp_options_id
}

# VM1: ArgoCD + GitOps Core (PAYG with 2GB)
resource "oci_core_instance" "tca_argocd_vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "tca-hybrid-argocd"
  shape               = "VM.Standard.E2.1.Micro"

  # PAYG Advantage: Professional memory allocation
  shape_config {
    ocpus         = 0.125  # Always Free eligible
    memory_in_gbs = 2      # Upgraded for stable ArgoCD - ~$1.20/month
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tca_subnet.id
    display_name     = "tca-argocd-vnic"
    assign_public_ip = true
    hostname_label   = "tca-argocd"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvqeklhziahqnxddk3gsca" # Ubuntu 22.04
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init-argocd-hybrid.yaml", {
      hostname = "tca-argocd"
      vm2_private_ip = oci_core_instance.tca_monitoring_vm.private_ip
      github_token = var.github_token
    }))
  }

  freeform_tags = {
    "Project" = "TCA-InfraForge-Hybrid"
    "Component" = "ArgoCD-Core"
    "Role" = "GitOps-Platform"
    "CostCenter" = "Professional-Development"
  }
}

# VM2: Monitoring & Observability (Always Free)
resource "oci_core_instance" "tca_monitoring_vm" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "tca-hybrid-monitoring"
  shape               = "VM.Standard.E2.1.Micro"

  shape_config {
    ocpus         = 0.125  # Always Free eligible
    memory_in_gbs = 1      # Stay within Always Free
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tca_subnet.id
    display_name     = "tca-monitoring-vnic"
    assign_public_ip = true
    hostname_label   = "tca-monitoring"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvqeklhziahqnxddk3gsca" # Ubuntu 22.04
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init-monitoring-hybrid.yaml", {
      hostname = "tca-monitoring"
      vm1_private_ip = oci_core_instance.tca_argocd_vm.private_ip
    }))
  }

  freeform_tags = {
    "Project" = "TCA-InfraForge-Hybrid"
    "Component" = "Observability"
    "Role" = "Monitoring-Stack"
    "CostCenter" = "Always-Free"
  }
}

# Load Balancer for professional access
resource "oci_load_balancer" "tca_lb" {
  shape          = "flexible"
  compartment_id = var.compartment_ocid
  subnet_ids     = [oci_core_subnet.tca_subnet.id]
  display_name   = "tca-hybrid-lb"

  shape_details {
    minimum_bandwidth_in_mbps = 10  # Always Free limit
    maximum_bandwidth_in_mbps = 10  # Always Free limit
  }

  freeform_tags = {
    "Project" = "TCA-InfraForge-Hybrid"
    "Component" = "LoadBalancer"
  }
}

# Outputs for hybrid architecture
output "tca_hybrid_info" {
  value = {
    # Access URLs
    argocd_url = "http://${oci_core_instance.tca_argocd_vm.public_ip}:8080"
    gitea_url = "http://${oci_core_instance.tca_argocd_vm.public_ip}:3000"  
    grafana_url = "http://${oci_core_instance.tca_monitoring_vm.public_ip}:3001"
    
    # SSH Access
    ssh_argocd = "ssh ubuntu@${oci_core_instance.tca_argocd_vm.public_ip}"
    ssh_monitoring = "ssh ubuntu@${oci_core_instance.tca_monitoring_vm.public_ip}"
    
    # Infrastructure details
    vm1_public_ip = oci_core_instance.tca_argocd_vm.public_ip
    vm1_private_ip = oci_core_instance.tca_argocd_vm.private_ip
    vm2_public_ip = oci_core_instance.tca_monitoring_vm.public_ip
    vm2_private_ip = oci_core_instance.tca_monitoring_vm.private_ip
  }
}

output "tca_hybrid_credentials" {
  value = {
    argocd_admin = "admin"
    argocd_password_location = "Available in ArgoCD secret after deployment"
    gitea_admin = "tca-admin"
    gitea_password = "tca-hybrid-2024"
    grafana_admin = "admin"
    grafana_password = "tca-hybrid-2024"
  }
  sensitive = true
}

output "tca_cost_breakdown" {
  value = {
    vm1_cost = "~$1.20/month (2GB RAM - 1GB over Always Free)"
    vm2_cost = "$0.00/month (Always Free eligible)"
    network_storage = "$0.00/month (Always Free eligible)"
    total_monthly = "~$1.70/month"
    annual_cost = "~$20/year"
    roi_note = "Professional GitOps platform for career development"
  }
}