---
title: "Managing Configurations for Prometheus and Grafana Helm Charts"
date: 2023-07-21 12:00:00 -0000
categories: devops kubernetes helm observability prometheus grafana
---

### Diagram

#### [Managing Prometheus and Grafana via Helm (draw.io viewer)](https://app.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=DevOps-Observability-Prometheus_Grafana_Helm.drawio#Uhttps%3A%2F%2Fraw.githubusercontent.com%2FAdam-Lechnos%2Fdiagrams-charts%2Fmain%2Fdevops%2FDevOps-Observability-Prometheus_Grafana_Helm.drawio){:target="_blank" rel="noopener"}

![Managing Prometheus and Grafana via Helm]({{ site.github-content }}/devops/DevOps-Observability-Prometheus_Grafana_Helm.drawio.svg?raw=true)

*This blog post is in specific reference to the [Kube Prometheus Stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) as part of the Prometheus Community, `prometheus-community/kube-prometheus-stack`*

When using the Helm Charts managed by the [Prometheus Monitoring Community](https://github.com/prometheus-community) repo, certain considerations should be made when managing the Prometheus configuration options such as Alerting Rules and Scrape Configs. This post will attempt to break-down best practices using the Kubernetes [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) (CRDs) created by the helm chart deployment.

### Why CRDs?

Making changes the the CRDs objects or creating new CRDs as defined by the helm charts enables a more clean and consistent approach to managing the configuration options for Prometheus and Grafana. Changes or additions to the CRD will perform an automated config reload against the Prometheus or Grafana objects in Kubernetes. In addition, future updates the the helm charts will prevent your custom values from being overwritten.

This is in contrast to making changes by first pulling in the `Values.yaml`, editing then updating the helm charts using the `-f` flag. Using this method requires a manual reload by calling the service endpoints for the Prometheus deployment using CURL.

You may determine the reload endpoint by executing the following command against your Kubernetes cluster:
 * `kubectl get sts <helm release>-prometheus-kube-prometheus-prometheus -n <namespace> -o yaml | grep reload-url`

### Available Prometheus CRDs

To check for available CRD object which may be editing or created, execute the following command :
* `kubectl get crds -n <namespace>`

Each of the listed CRDs may then be called against the Kubernetes API like any other Kubernetes Object, such as a Deployments or StatefulSets. For example, for the `alertmanagers.monitoring.coreos.com` CRD, you may list its existing objects by executing
* `kubectl get alertmanagerconfigs -n <namespace>`

I will now delve into the key CRDs to create/update when managing the Helm Chart Configs for Prometheus and Grafana.

### Alerting Rules

The alerting rules are managed by the `prometheusrules.monitoring.coreos.com` CRD which handles registering new rules to Prometheus. Learn more at the official [Prometheus Documentation - Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

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
The `metadata.labels` section must match what is configured for the CRD. Check the existing CRD by running `kubectl get prometheuses <helm release>-kube-prometheus-prometheus -n <namespace> -o yaml | grep -i matchlabels -A5`

The output will show the `matchLabels:` selector.

### Scrape Configs

Managed by the `servicemonitor.monitoring.coreos.com` CRD which specified a set of targets and parameters describing how to scrape them. Learn more at the official [Prometheus Documentation - Configuration/Scrape Config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

**Note:** When creating a scraper ensure a Kubernetes Service object exists exposing the service against the Pod/ReplicaSet/StatefulSet/daemonSet/Deplyoment.

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

Note the `spec.namespaceSelector` and `spec.selector` to ensure the ServiceMonitor selects the Kubernetes objects containing the custom metrics URL path such as Deployments, Pods, or StatefulSets.

The `spec.endpoints` section must reference a port's name inside of a service object which exposes the service objects such as NodePort or ClusterIP.

The `metadata.labels` section must match what is configured for the CRD. Check the existing CRD by running `kubectl get servicemonitors <helm release>-kube-prometheus-prometheus -n monitoring -o yaml | grep -i matchLabels -A`

The output will show the `matchLabels:` selector.

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
      receiver "infra"
      groupBy: ["severity"]
```

The `metadata.labels` section must match what is configured for the CRD. Check the existing CRD by running `kubectl get alertmanagers <helm release>-kube-prometheus-alertmanager -n <namespace> -o yaml | grep -i selector`

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
