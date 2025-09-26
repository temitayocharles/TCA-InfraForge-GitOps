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
        --set ports.web.port=80 \
        --set ports.websecure.port=443 \
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
      
      echo "✅ TCA-InfraForge: Traefik installation completed!"
      echo "🌐 Dashboard available at: http://localhost:8070/dashboard"
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
      
      # Create IngressRoutes for all services
      cat <<YAML | kubectl apply -f -
# ArgoCD IngressRoute
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
  labels:
    tca.infraforge/component: ingress-route
spec:
  entryPoints:
    - web
  routes:
  - match: Host(\`localhost\`) && PathPrefix(\`/argocd\`)
    kind: Rule
    services:
    - name: argocd-server
      port: 80
    middlewares:
    - name: argocd-stripprefix
---
# ArgoCD Middleware to strip /argocd prefix
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: argocd-stripprefix
  namespace: argocd
spec:
  stripPrefix:
    prefixes:
      - /argocd
---
# Grafana IngressRoute
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: grafana
  namespace: monitoring
  labels:
    tca.infraforge/component: ingress-route
spec:
  entryPoints:
    - web
  routes:
  - match: Host(\`localhost\`) && PathPrefix(\`/grafana\`)
    kind: Rule
    services:
    - name: kube-prometheus-stack-grafana
      port: 80
    middlewares:
    - name: grafana-stripprefix
---
# Grafana Middleware
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: grafana-stripprefix
  namespace: monitoring
spec:
  stripPrefix:
    prefixes:
      - /grafana
---
# Traefik Dashboard IngressRoute
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
  - match: Host(\`localhost\`) && PathPrefix(\`/dashboard\`)
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