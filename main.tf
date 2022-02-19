locals {
  selector_labels = {
    "app.kubernetes.io/name"      = var.name
    "app.kubernetes.io/component" = "prometheus-pushgateway"
  }
  labels = merge(local.selector_labels, {
    "app.kubernetes.io/managed-by" = "terraform-kubernetes-prometheus-pushgateway"
    "app.kubernetes.io/version"    = var.pushgateway-image-tag
  })
}

resource "kubernetes_deployment" "pushgateway" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.selector_labels
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        container {
          image = "${var.pushgateway-image}:${var.pushgateway-image-tag}"
          name  = var.name
          port {
            container_port = 9091
            protocol       = "TCP"
          }
          resources {
            requests = var.requests
            limits   = var.limits
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_group               = 2000
            run_as_non_root            = true
            run_as_user                = 1000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pushgateway" {
  metadata {
    labels    = local.labels
    name      = var.name
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "web"
      port        = 9091
      protocol    = "TCP"
      target_port = kubernetes_deployment.pushgateway.spec[0].template[0].spec[0].container[0].port[0].container_port
    }
    selector = local.selector_labels
  }
}

resource "kubernetes_manifest" "pushgateway-service-monitor" {
  provider = kubernetes

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata"   = {
      "labels"    = merge(local.labels, var.servicemonitor-label)
      "name"      = var.name
      "namespace" = var.namespace
    }
    "spec" = {
      "endpoints" = [
        {
          path = "/metrics"
          port = kubernetes_service.pushgateway.spec[0].port[0].name
        },
      ]
      "namespaceSelector" = {
        "matchNames" = [
          var.namespace,
        ]
      }
      "selector" = {
        "matchLabels" = local.selector_labels
      }
    }
  }
}
