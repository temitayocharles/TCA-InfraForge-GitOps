# TCA-InfraForge Terraform Configuration
# Author: Temitayo Charles Akinniranye
# Purpose: Provision Kind cluster with ArgoCD for GitOps demonstration

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  
  # For demo/development: local backend works perfectly
  # For production: consider S3 backend with state locking
  # backend "s3" {
  #   bucket = "tca-infraforge-terraform-state"
  #   key    = "demo/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
  default     = "tca-infraforge-demo"
}

variable "argocd_version" {
  description = "ArgoCD version to install"
  type        = string
  default     = "v2.8.4"
}

# Create Kind cluster for TCA-InfraForge demo
resource "null_resource" "tca_kind_cluster" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "🚀 TCA-InfraForge: Creating Kind cluster..."
      
      # Install Kind if not present
      if ! command -v kind &> /dev/null; then
        echo "📦 Installing Kind..."
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
      fi
      
      # Create cluster with TCA branding
      echo "🚀 Creating Kind cluster: ${var.cluster_name}..."
      if ! kind create cluster \
        --name "${var.cluster_name}" \
        --config ${path.module}/kind-config.yaml; then
        echo "❌ Failed to create Kind cluster"
        exit 1
      fi
      
      # Verify cluster exists
      if ! kind get clusters | grep -q "${var.cluster_name}"; then
        echo "❌ Cluster ${var.cluster_name} not found after creation"
        exit 1
      fi
      
      # Set kubeconfig context
      kubectl config use-context "kind-${var.cluster_name}"
      
      # Wait for cluster to be ready
      echo "⏳ Waiting for cluster to be fully ready..."
      kubectl wait --for=condition=Ready nodes --all --timeout=300s
      
      echo "✅ TCA-InfraForge cluster '${var.cluster_name}' created successfully!"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🧹 TCA-InfraForge: Destroying Kind cluster..."
      kind delete cluster --name "${self.triggers.cluster_name}" || true
      echo "✅ TCA-InfraForge cluster cleanup completed!"
    EOT
  }
  
  triggers = {
    cluster_name = var.cluster_name
  }
}

# Install ArgoCD on the TCA cluster
resource "null_resource" "tca_argocd_install" {
  depends_on = [null_resource.tca_kind_cluster]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🎯 TCA-InfraForge: Installing ArgoCD ${var.argocd_version}..."
      
      # Ensure we're using the correct context
      kubectl config use-context "kind-${var.cluster_name}"
      
      # Create ArgoCD namespace
      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
      
      # Install ArgoCD
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${var.argocd_version}/manifests/install.yaml
      
      # Label namespace for TCA branding
      kubectl label namespace argocd \
        app.kubernetes.io/managed-by=tca-infraforge \
        tca.infraforge/project=gitops-demo \
        --overwrite
      
      # Wait for ArgoCD to be ready
      echo "⏳ Waiting for ArgoCD to be ready..."
      kubectl wait --for=condition=available --timeout=600s \
        deployment/argocd-server -n argocd
      
      # Configure ArgoCD for demo
      kubectl patch configmap argocd-cmd-params-cm -n argocd \
        --patch='{"data":{"server.insecure":"true"}}' || true
      
      # Restart ArgoCD server to pick up config
      kubectl rollout restart deployment/argocd-server -n argocd
      kubectl wait --for=condition=available --timeout=300s \
        deployment/argocd-server -n argocd
      
      echo "✅ TCA-InfraForge: ArgoCD installation completed!"
    EOT
  }
  
  triggers = {
    cluster_name    = var.cluster_name
    argocd_version = var.argocd_version
  }
}

# Configure TCA ArgoCD projects and applications
resource "null_resource" "tca_argocd_config" {
  depends_on = [null_resource.tca_argocd_install, null_resource.tca_traefik_install]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🏗️ TCA-InfraForge: Configuring ArgoCD projects..."
      
      # Apply TCA projects and applications
      if [ -d "${path.root}/../argocd" ]; then
        kubectl apply -f ${path.root}/../argocd/projects/ || true
        sleep 10
        kubectl apply -f ${path.root}/../argocd/applications/ || true
      fi
      
      echo "✅ TCA-InfraForge: ArgoCD configuration completed!"
    EOT
  }
  
  triggers = {
    cluster_name = var.cluster_name
  }
}

# Outputs for TCA-InfraForge demo
output "tca_cluster_info" {
  value = {
    cluster_name = var.cluster_name
    context_name = "kind-${var.cluster_name}"
    argocd_version = var.argocd_version
  }
  description = "TCA-InfraForge cluster information"
}

output "tca_access_instructions" {
  value = <<-EOT
    🎉 TCA-InfraForge Demo Ready!
    
    📋 Cluster: ${var.cluster_name}
    🎯 ArgoCD Version: ${var.argocd_version}
    
    🌐 Access URLs (All via Traefik Ingress):
    - ArgoCD UI: http://localhost:8070/argocd
    - Grafana: http://localhost:8070/grafana  
    - Traefik Dashboard: http://localhost:8070/dashboard
    
    🔑 Get ArgoCD Admin Password:
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    
    📊 Default Grafana Login:
    - Username: admin
    - Password: tca-demo-password
    
    🎯 All services accessed through Traefik on port 8070 with path-based routing!
    
    👨‍💻 Built by: Temitayo Charles Akinniranye
  EOT
  description = "Instructions to access TCA-InfraForge demo"
}