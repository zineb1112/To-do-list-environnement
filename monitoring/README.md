# Automated Kubernetes Monitoring

This repository provides automated Loki + Grafana Alloy + Grafana monitoring.

## What is automated?

- Loki installation
- Alloy installation
- Grafana installation
- Log labels
- 7-day Loki retention
- GitHub Actions deployment logs
- Application Logs dashboard
- Deployment Logs dashboard
- Error/deployment alert rules
- Verification

## Deployment

The main automation is:

`.github/workflows/monitoring.yml`

It uses a self-hosted GitHub Actions runner for Docker Desktop Kubernetes.

## Local access

Grafana:
http://localhost:30030

Loki:
http://localhost:31000

Development Grafana login:
`admin` / `admin`

## Structure

```text
.github/workflows/monitoring.yml
helm/
  loki-values.yaml
  alloy-values.yaml
  grafana-values.yaml
  grafana/
    Chart.yaml
    values.yaml
    dashboards/
    alerting/
    templates/
github-actions/
scripts/
docs/
```

## Important

This package is intended for the existing Docker Desktop Kubernetes environment. Before production use, configure secrets securely and replace local filesystem/NodePort settings with production storage/networking.
