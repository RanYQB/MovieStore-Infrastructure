resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-operator"
  version    = "15.0.0"

  namespace = "monitoring"

  values = [
    # Customize values as needed
    # For example, you can configure Alertmanager, Prometheus, etc.
    # See Prometheus Operator documentation for available options
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "5.2.0"

  namespace = "monitoring"

  values = [
    # Customize values as needed
    # For example, you can configure datasources to point to Prometheus
    # See Grafana documentation for available options
  ]
}

resource "kubernetes_manifest" "memory_cpu_prometheus_rule" {
  yaml_body = <<-EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: memory-cpu-usage
spec:
  groups:
  - name: memory-cpu.rules
    rules:
    - alert: HighMemoryUsage
      expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"

    - alert: HighCPUUsage
      expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
EOF
}

resource "kubernetes_manifest" "pricing_alert" {
  yaml_body = <<-EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-cost-alert
spec:
  groups:
  - name: kubernetes-cost.rules
    rules:
    - alert: HighCost
      expr: sum(rate(azure_compute_estimated_cost_total{namespace="kube-system"}[1h])) by (project) > 100
      for: 15m
      labels:
        severity: critical
      annotations:
        summary: "High cost for Kubernetes cluster"
EOF
}
