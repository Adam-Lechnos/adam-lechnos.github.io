---
title: "Managing Configurations for Prometheus and Grafana Helm Charts"
date: 2023-07-21 12:00:00 -0000
categories: devops kubernetes helm observability prometheus grafana
---

### Diagram

#### [Managing Prometheus and Grafana via Helm (draw.io viewer)](https://app.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=DevOps-Observability-Prometheus_Grafana_Helm.drawio#Uhttps%3A%2F%2Fraw.githubusercontent.com%2FAdam-Lechnos%2Fdiagrams-charts%2Fmain%2Fdevops%2FDevOps-Observability-Prometheus_Grafana_Helm.drawio){:target="_blank" rel="noopener"}

![Managing Prometheus and Grafana via Helm]({{ site.github-content }}/devops/DevOps-Observability-Prometheus_Grafana_Helm.drawio.svg?raw=true)
*The Prometheus Operator manages the CRDs. The Values.yaml and CRDs impacts each object's configuration*

*This blog post is in specific reference to the [Kube Prometheus Stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack){:target="_blank" rel="noopener"} as part of the Prometheus Community, `prometheus-community/kube-prometheus-stack`*

When using the Helm Charts managed by the [Prometheus Monitoring Community](https://github.com/prometheus-community){:target="_blank" rel="noopener"} repo, certain considerations should be made when managing the Prometheus configuration options such as Alerting Rules and Scrape Configs. This post will attempt to break-down best practices using the Kubernetes [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/){:target="_blank" rel="noopener"} (CRDs) created by the helm chart deployment.

### Why CRDs?

Making changes the the CRDs objects or creating new CRDs as defined by the helm charts enables a more clean and consistent approach to managing the configuration options for Prometheus and Grafana. Changes or additions to the CRD will perform an automated config reload against the Prometheus or Grafana objects in Kubernetes. In addition, future updates the the helm charts will prevent your custom values from being overwritten.

This is in contrast to making changes by first pulling in the `Values.yaml`, editing then updating the helm charts using the `-f` flag. Using this method requires a manual reload by calling the service endpoints for the Prometheus deployment using CURL.
These CRDs are defined and managed by the [Prometheus Operator](https://artifacthub.io/packages/olm/community-operators/prometheus){:target="_blank" rel="noopener"} built into the aforementioned helm chart.

You may determine the reload endpoint by executing the following command against your Kubernetes cluster:
 * `kubectl get sts <helm release>-prometheus-kube-prometheus-prometheus -n <namespace> -o yaml | grep reload-url`

### Available Prometheus CRDs

To check for available CRD object which may be editing or created, execute the following command:
* `kubectl get crds -n <namespace>`

Each of the listed CRDs may then be called against the Kubernetes API like any other Kubernetes Object, such as a Deployments or StatefulSets. For example, for the `alertmanagers.monitoring.coreos.com` CRD, you may list its existing objects by executing
* `kubectl get alertmanagerconfigs -n <namespace>`

New resources created as defined by each of the CRDs must contain the configured key/value CRD label selector when populating the `metadata.labels` object. This enables Prometheus Service Discovery to discover the endpoints as referenced by these new resources. For example, when creating a new ServiceMonitor object for scraping a custom metrics endpoint, the endpoints referenced by the new object are not discoverable by prometheus unless the `metadata.labels` also matches the underlying CRD config.

I will now delve into the key CRDs to create/update when managing the Helm Chart Configs for Prometheus and Grafana.

### Alerting Rules

The alerting rules are managed by the `prometheusrules.monitoring.coreos.com` CRD which define alert conditions for Prometheus. Learn more at the official [Prometheus Documentation - Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

Create a yaml manifest as follows to add a new alert rule:

``` yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    release: prometheus
  name: prometheus-example-rules
spec:
  groups:
  - name: ./example.rules
    rules:
    - alert: down
      expr: up==0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: prometheus
```
The `metadata.labels` section must contain the key/value for what is configured for the underlying CRD. Check the existing CRD by running `kubectl get prometheuses <helm release>-kube-prometheus-prometheus -n <namespace> -o yaml | grep -i matchlabels -A5`

The output will show the `matchLabels:` selector.

### Scrape Configs

Managed by the `servicemonitor.monitoring.coreos.com` CRD which specifies a set of targets and parameters describing how to scrape them. Learn more at the official [Prometheus Documentation - Configuration/Scrape Config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

**Note:** When creating a scrape config, ensure a Kubernetes Service object exists exposing the service against the Pod/ReplicaSet/StatefulSet/daemonSet/Deployment.

Create a yaml manifest as follows to add a new scrape config:

``` yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: servicemonitor-app
  labels:
    app: servicemonitor-app
    release: prometheus
spec:
  endpoints:
  - port: http-metrics
    path: /url/paths
    interval: 30s
  namespaceSelector:
    matchNames:
      - service-monitor-namespace
  selector:
    matchLabels:
      instance: service
```

Note the `spec.namespaceSelector` and `spec.selector` work together to ensure the ServiceMonitor selects the Kubernetes objects containing the custom metrics URL path such as Deployments, Pods, or StatefulSets.

The `spec.endpoints` section must reference a port's name inside of a Service which exposes its underlying objects such as NodePort or ClusterIP.

The `metadata.labels` section must contain the key/value for what is configured for the underlying CRD. Check the existing CRD by running `kubectl get servicemonitors <helm release>-kube-prometheus-prometheus -n monitoring -o yaml | grep -i matchLabels -A`

The output will show the `matchLabels:` selector.

#### Exporters
Scrape Configs are also required when adding or writing a [Prometheus Exporter](https://prometheus.io/docs/instrumenting/exporters/){:target="_blank" rel="noopener"} such as for [Redis](https://prometheus.io/docs/instrumenting/exporters/){:target="_blank" rel="noopener"}.These exporters act as a translation layer between the application and Prometheus, exposing an additional `/metrics` endpoint, sometimes using a sidecar container. These exporters also exist as [Docker Images](https://hub.docker.com/search?q=exporter&categories=Integration%20%26%20Delivery%2CMonitoring%20%26%20Observability){:target="_blank" rel="noopener"} in Docker Hub.

It is recommended to add an Exporter, if not already built into the Helm chart maintained for the application in question, by first searching for an existing Exporter within [Artifact Hub](https://artifacthub.io/packages/search?category=4&ts_query_web=prometheus+exporter&sort=relevance&page=1){:target="_blank" rel="noopener"}.

[Redis Helm Chart](https://artifacthub.io/packages/helm/bitnami/redis){:target="_blank" rel="noopener"} for example contains a sidecar container for exposing Redis application metrics.

When installing an add-on Exporter via Helm, its `Values.yaml` should be updated to match the key/value label as specified in the `metadata.labels` above, in addition to the correct Service Name and Port as determined by the Service created to expose the application.

* You may use the `helm show values <repo/helm-chart> > values.yaml` and `helm install (or upgrade) <release> -f values.yaml` method to accomplish this. See the chart's documentation for more details.

The `serviceMonitor` section is what instructs the helm chart to spin-up a new ServiceMonitor CRD with the correct `metadata.labels` directive in lieu of the manual steps defined above. If a comparable `serviceMonitor` directive does not exist, manual steps must be taken to create each of the ServiceMonitor as defined above. In addition, if a Service is not created which exposes the Exporter pod, create one manually.

Example Exporter Match Label Config Snippet:
``` yaml
mongodb:
  uri: "mongodb://mongodb-service:27017" # points to the existing Service for MongoDB

serviceMonitor:
  additionalLabels:
    release: prometheus # must match what is configured for the ServiceMonitor CRD. 
```

Check the Service created by the Exporter's helm chart via port forwarding or creating an additional NodePort, then attempt to browse to the exposed scrape URL path, usually `/metrics`. You should also see the new ServiceMonitor listed as a Target in the Prometheus UI with its detected endpoints.

### Alert Manager Rules

Managed by the `alertmanager.monitoring.coreos.com` CRD which handles alerts sent by the client application. It takes care of grouping and routing alerts to the correct receiver. Learn more at the official [Prometheus Documentation - AlertManger](https://prometheus.io/docs/alerting/latest/alertmanager/).

Create a yaml as follows to add a new alert manager rule:

``` yaml
apiVersion: monitoring.coreos.com/v1
kind: AlertManager
metadata:
  name: servicemonitor-app
  labels:
    app: servicemonitor-app
    release: prometheus
spec:
  route:
    groupBy: ["alertname"]
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: "webhook"
    routes:
    - matchers:
      - name: job
        value: kubernetes
      receiver: "infra"
      groupBy: ["severity"]
```

The `metadata.labels` section must contain the key/value for what is configured for the underlying CRD. Check the existing CRD by running `kubectl get alertmanagers <helm release>-kube-prometheus-alertmanager -n <namespace> -o yaml | grep -i selector`

If the `alertmanagerConfigSelector` value is empty, it must first be specified by the following steps:
  * Execute `helm show values prometheus-community/kube-prometheus-stack > values.yaml`
  * Edit the values.yaml by searching `alertmanagerConfigSelector`. Remove the value `{}` and replace with:
     ``` yaml
     alertmanagerConfigSelector:
      matchLabels:
        resource: prometheus
     ```
  * Execute `helm upgrade <helm release> prometheus-community/kube-prometheus-stack -f values.yaml`

### Using Helm Values

You may also edit the aforementioned config values by editing the `values.yaml`. This is not recommended as further updates to the helm-chart may override these values.

* Execute `helm show values prometheus-community/kube-prometheus-stack > values.yaml`
* Edit the values.yaml for the following configuration options (examples to uncomment are provided):
  * Scrape Config - `additionalScrapeConfigs` [(example)](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L3812){:target="_blank" rel="noopener"}
  * Alerting Rules - `additionalPrometheusRulesMap` [(example)](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L194){:target="_blank" rel="noopener"}
  * Alert Manager Config - `alertManagerConfiguration` [(example)](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L726){:target="_blank" rel="noopener"}
* Execute `helm upgrade <helm release> prometheus-community/kube-prometheus-stack -f values.yaml`
