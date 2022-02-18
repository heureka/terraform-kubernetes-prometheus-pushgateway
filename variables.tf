variable "name" {
  type        = string
  description = "Name of the app that's going to be using this pushgateway, or just name of the pushgateway"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use"
}

variable "pushgateway-image" {
  type        = string
  description = "Image to use"

  default = "quay.io/prometheus/pushgateway"
}

variable "pushgateway-image-tag" {
  type        = string
  description = "Tag of the pushgateway image to use"

  default = "v1.4.2"
}

variable "requests" {
  type        = map(string)
  description = "requests for the deployment"

  default = {
    cpu    = "100m"
    memory = "128Mi"
  }
}

variable "limits" {
  type        = map(string)
  description = "limits for the deployment"

  default = var.requests
}

variable "servicemonitor-label" {
  type = map(string)
  description = "Special label for ServiceMonitor resource, in case your prometheus has `serviceMonitorSelector` set"

  default = {}
}
