# TCA-InfraForge Traefik Configuration
# Traefik: Modern reverse proxy with automatic service discovery

# Install Traefik via ArgoCD (GitOps way)
resource "null_resource" "tca_traefik_install" {
  depends_on = [null_resource.tca_argocd_install]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🌐 TCA-InfraForge: Installing Traefik..."
      
      # Create Traefik namespace
      kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -
      
      # Label namespace for TCA branding
      kubectl label namespace traefik \
        app.kubernetes.io/managed-by=tca-infraforge \
        tca.infraforge/component=ingress \
        --overwrite
      
      # Install Traefik via Helm
      helm repo add traefik https://traefik.github.io/charts || true
      helm repo update
      
      helm upgrade --install traefik traefik/traefik \
        --namespace traefik \
        --set deployment.replicas=1 \
        --set service.type=LoadBalancer \
        --set ports.web.port=8000 \
        --set ports.websecure.port=8443 \
        --set ports.traefik.port=9000 \
        --set ingressRoute.dashboard.enabled=true \
        --set providers.kubernetesCRD.enabled=true \
        --set providers.kubernetesIngress.enabled=true \
        --set globalArguments[0]="--global.checknewversion=false" \
        --set globalArguments[1]="--global.sendanonymoususage=false" \
        --set additionalArguments[0]="--log.level=INFO" \
        --set additionalArguments[1]="--accesslog=true" \
        --set additionalArguments[2]="--metrics.prometheus=true" \
        --set additionalArguments[3]="--metrics.prometheus.addEntryPointsLabels=true" \
        --set additionalArguments[4]="--metrics.prometheus.addServicesLabels=true" \
        --wait
        
      # Wait for Traefik to be ready
      kubectl wait --for=condition=available --timeout=300s \
        deployment/traefik -n traefik
        
      # Expose Traefik dashboard
      kubectl port-forward -n traefik service/traefik 9070:9000 > /dev/null 2>&1 &
      echo $! > traefik-port-forward.pid
      
      echo "✅ TCA-InfraForge: Traefik installation completed!"
      echo "🌐 Dashboard available at: http://localhost:9070"
    EOT
  }
  
  triggers = {
    cluster_name = var.cluster_name
  }
}

# Create IngressRoute for ArgoCD via Traefik
resource "null_resource" "tca_traefik_routes" {
  depends_on = [null_resource.tca_traefik_install]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🌐 TCA-InfraForge: Setting up Traefik routes..."
      
      # Create IngressRoute for ArgoCD
      cat <<YAML | kubectl apply -f -
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
  labels:
    tca.infraforge/component: traefik-route
spec:
  entryPoints:
    - web
  routes:
  - match: Host(\`argocd.tca-infraforge.dev\`)
    kind: Rule
    services:
    - name: argocd-server
      port: 80
---
apiVersion: traefik.containo.us/v1alpha1  
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: traefik
  labels:
    tca.infraforge/component: traefik-dashboard
spec:
  entryPoints:
    - web
  routes:
  - match: Host(\`traefik.tca-infraforge.dev\`)
    kind: Rule
    services:
    - name: api@internal
      kind: TraefikService
YAML
      
      echo "✅ TCA-InfraForge: Traefik routes configured!"
    EOT
  }
  
  triggers = {
    cluster_name = var.cluster_name
  }
}