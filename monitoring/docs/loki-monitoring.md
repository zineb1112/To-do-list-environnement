# Loki / Alloy / Grafana Monitoring

## Purpose

This repository automates the monitoring stack for Kubernetes.

## Components

- Loki: log storage and querying
- Grafana Alloy: Kubernetes log collection
- Grafana: dashboards and alerting
- Helm: deployment and configuration
- GitHub Actions: automation

Promtail is intentionally not used; Alloy is the log collector.

## Tasks

- #41 Loki installation: automated with Helm
- #42 Log collection: automated with Alloy DaemonSet
- #43 Labels: namespace, pod, container, service, environment, version, deploymentId
- #44 Retention: 168 hours / 7 days
- #45 GitHub Actions logs: pushed to Loki by workflow
- #46 Application dashboard: provisioned automatically
- #47 Deployment dashboard: provisioned automatically
- #48 Alerts: application error spike and deployment failure
- #49 Documentation: this document

## Local endpoints

Grafana:
http://localhost:30030

Loki NodePort:
http://localhost:31000

Default development Grafana credentials:
admin / admin

Change the password before using this outside local development.

## Automation

The normal deployment path is:

Git push -> GitHub Actions -> Helm -> Kubernetes

The GitHub Actions workflow is configured for a self-hosted runner because the local Docker Desktop Kubernetes cluster is running on the developer machine.

## Important

Before production/cloud deployment, replace local NodePort access, default credentials, and filesystem storage with environment-appropriate configuration and secrets.
