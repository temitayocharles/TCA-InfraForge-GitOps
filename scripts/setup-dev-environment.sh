#!/bin/bash
# TCA-InfraForge Developer Environment Setup Script
# Usage: ./setup-dev-environment.sh <developer-name>

set -e

DEVELOPER_NAME="${1}"
NAMESPACE="dev-${DEVELOPER_NAME}"
ARGOCD_PROJECT="${DEVELOPER_NAME}-dev"

if [ -z "$DEVELOPER_NAME" ]; then
    echo "❌ Error: Please provide a developer name"
    echo "Usage: $0 <developer-name>"
    echo "Example: $0 alice"
    exit 1
fi

echo "🚀 Setting up development environment for: $DEVELOPER_NAME"

# Validate developer name (alphanumeric and hyphens only)
if [[ ! "$DEVELOPER_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo "❌ Error: Developer name must be lowercase alphanumeric with hyphens only"
    exit 1
fi

echo "📋 Creating Kubernetes namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Label namespace for monitoring and policies
kubectl label namespace "$NAMESPACE" \
    tca.infraforge/developer="$DEVELOPER_NAME" \
    tca.infraforge/environment="development" \
    istio-injection=enabled \
    --overwrite

echo "🎯 Setting up ArgoCD project and permissions..."

# Create ArgoCD project for the developer
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: $ARGOCD_PROJECT
  namespace: argocd
  labels:
    tca.infraforge/developer: $DEVELOPER_NAME
    tca.infraforge/type: developer-project
spec:
  description: "Development project for $DEVELOPER_NAME"
  
  sourceRepos:
  - 'https://github.com/*/TCA-InfraForge'
  - 'https://github.com/*/TCA-InfraForge.git'
  - 'https://*.helm.sh/*'
  - 'https://kubernetes-sigs.github.io/*'
  - 'https://charts.bitnami.com/*'
  - '*'
  
  destinations:
  - namespace: $NAMESPACE
    server: https://kubernetes.default.svc
    
  clusterResourceWhitelist: []
  
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
    
  roles:
  - name: developer
    description: "Full access to developer's namespace"
    policies:
    - p, proj:$ARGOCD_PROJECT:developer, applications, *, $ARGOCD_PROJECT/*, allow
    - p, proj:$ARGOCD_PROJECT:developer, repositories, *, *, allow
    groups:
    - tca-infraforge:$DEVELOPER_NAME
EOF

echo "📊 Setting up monitoring and observability..."

# Create ServiceMonitor for developer applications
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: $DEVELOPER_NAME-apps
  namespace: $NAMESPACE
  labels:
    tca.infraforge/developer: $DEVELOPER_NAME
spec:
  selector:
    matchLabels:
      tca.infraforge/developer: $DEVELOPER_NAME
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
EOF

# Create resource quota for fair resource sharing
echo "⚖️ Setting up resource quotas..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: $DEVELOPER_NAME-quota
  namespace: $NAMESPACE
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
    services: "5"
    persistentvolumeclaims: "3"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: $DEVELOPER_NAME-limits
  namespace: $NAMESPACE
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
EOF

echo "🔐 Setting up network policies..."

# Create network policy for namespace isolation
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: $DEVELOPER_NAME-isolation
  namespace: $NAMESPACE
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - namespaceSelector:
        matchLabels:
          name: $NAMESPACE
  egress:
  - {}  # Allow all egress for simplicity in development
EOF

echo "🎨 Creating application templates..."

# Create application directory
mkdir -p "argocd/applications/dev-$DEVELOPER_NAME"

# Create sample application template
cat <<EOF > "argocd/applications/dev-$DEVELOPER_NAME/sample-app.yaml"
# Sample Application for $DEVELOPER_NAME
# Copy this file and modify for your applications

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $DEVELOPER_NAME-sample-app
  namespace: argocd
  labels:
    tca.infraforge/developer: $DEVELOPER_NAME
    tca.infraforge/app-type: sample
spec:
  project: $ARGOCD_PROJECT
  
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: nginx
    targetRevision: 15.4.4
    helm:
      releaseName: $DEVELOPER_NAME-nginx
      values: |
        fullnameOverride: "$DEVELOPER_NAME-sample-app"
        
        commonLabels:
          tca.infraforge/developer: $DEVELOPER_NAME
          tca.infraforge/app: sample-nginx
          
        service:
          type: ClusterIP
          
        ingress:
          enabled: true
          hostname: $DEVELOPER_NAME-sample.tca-infraforge.dev
          annotations:
            kubernetes.io/ingress.class: nginx
            cert-manager.io/cluster-issuer: letsencrypt-prod
            
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
            
        podSecurityContext:
          runAsNonRoot: true
          runAsUser: 1001
          
  destination:
    server: https://kubernetes.default.svc
    namespace: $NAMESPACE
    
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=false
EOF

echo "✅ Development environment setup complete!"
echo ""
echo "🎯 Your Development Environment:"
echo "   Namespace: $NAMESPACE"
echo "   ArgoCD Project: $ARGOCD_PROJECT"
echo "   Application Directory: argocd/applications/dev-$DEVELOPER_NAME/"
echo ""
echo "🚀 Next Steps:"
echo "   1. Edit argocd/applications/dev-$DEVELOPER_NAME/sample-app.yaml"
echo "   2. Commit and push your changes"
echo "   3. Check ArgoCD UI: https://argocd.tca-infraforge.dev"
echo "   4. Monitor your apps: https://grafana.tca-infraforge.dev"
echo ""
echo "📚 Documentation: See README.md for detailed usage instructions"