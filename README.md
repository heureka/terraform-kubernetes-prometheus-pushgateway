# terraform-kubernetes-prometheus-pushgateway

For deploying Prometheus pushgateway in your kubernetes cluster

## Assumptions

* You are running prometheus operator (`monitoring.coreos.com/v1` in your cluster)
* Your instance of Kubernetes provider is able to apply CRDs (`kubernetes_manifest` resource)
  * This requires special setup of the provider, more information [here](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/alpha-manifest-migration-guide)

## Usage

```terraform
module "pushgateway" {
  source = "heureka/prometheus-pushgateway/kubernetes"
  version = "1.0.0"
  
  name                 = "my-apps-pgw"
  namespace            = "my-namespace"
  servicemonitor-label = {
    prometheus = "scrape-this"
  }
}
```
