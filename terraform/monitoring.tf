# TCA-InfraForge Monitoring Stack Terraform Configuration
# Author: Temitayo Charles Akinniranye

# Prometheus for metrics collection
resource "null_resource" "tca_prometheus_install" {
  depends_on = [null_resource.tca_argocd_install]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "📊 TCA-InfraForge: Installing Prometheus..."
      
      # Create monitoring namespace
      kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
      
      # Label namespace for TCA branding
      kubectl label namespace monitoring \
        app.kubernetes.io/managed-by=tca-infraforge \
        tca.infraforge/component=monitoring \
        --overwrite
      
      # Add Prometheus Helm repository
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
      helm repo update
      
      # Install Prometheus stack (includes Grafana)
      helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
        --set grafana.enabled=true \
        --set grafana.adminPassword="tca-demo-password" \
        --set grafana.service.type=LoadBalancer \
        --set grafana.service.port=3000 \
        --set alertmanager.enabled=false \
        --set nodeExporter.enabled=true \
        --set kubeStateMetrics.enabled=true \
        --set grafana.sidecar.dashboards.enabled=true \
        --set grafana.sidecar.datasources.enabled=true \
        --wait
        
      # Wait for Prometheus to be ready
      kubectl wait --for=condition=available --timeout=300s \
        deployment/kube-prometheus-stack-grafana -n monitoring
        
      # Port-forward Grafana for easy access  
      kubectl port-forward -n monitoring service/kube-prometheus-stack-grafana 3070:80 > /dev/null 2>&1 &
      echo $! > grafana-port-forward.pid
      
      echo "✅ TCA-InfraForge: Monitoring stack installation completed!"
      echo "📊 Grafana available at: http://localhost:3070"
      echo "🔑 Username: admin, Password: tca-demo-password"
    EOT
  }
  
  triggers = {
    cluster_name = var.cluster_name
  }
}

# Create basic Grafana dashboards
resource "null_resource" "tca_grafana_dashboards" {
  depends_on = [null_resource.tca_prometheus_install]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "📊 TCA-InfraForge: Setting up Grafana dashboards..."
      
      # Create ConfigMap with basic dashboard
      cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: tca-cluster-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
    tca.infraforge/component: dashboard
data:
  cluster-overview.json: |
    {
      "dashboard": {
        "id": null,
        "title": "TCA-InfraForge Cluster Overview",
        "tags": ["tca-infraforge", "kubernetes"],
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "Cluster Nodes",
            "type": "stat",
            "targets": [
              {
                "expr": "count(kube_node_info)",
                "legendFormat": "Total Nodes"
              }
            ],
            "fieldConfig": {
              "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {"displayMode": "list", "orientation": "auto"},
                "mappings": [],
                "thresholds": {"steps": [{"color": "green", "value": null}]}
              }
            },
            "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
          },
          {
            "id": 2,
            "title": "Total Pods",
            "type": "stat", 
            "targets": [
              {
                "expr": "count(kube_pod_info)",
                "legendFormat": "Total Pods"
              }
            ],
            "fieldConfig": {
              "defaults": {
                "color": {"mode": "palette-classic"},
                "mappings": [],
                "thresholds": {"steps": [{"color": "blue", "value": null}]}
              }
            },
            "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
          }
        ],
        "time": {"from": "now-1h", "to": "now"},
        "refresh": "30s"
      }
    }
YAML
      
      echo "✅ TCA-InfraForge: Grafana dashboards configured!"
    EOT
  }
  
  triggers = {
    cluster_name = var.cluster_name
  }
}