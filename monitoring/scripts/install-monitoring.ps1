$ErrorActionPreference = "Stop"

kubectl config use-context docker-desktop

kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

helm repo add grafana-community https://grafana-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana-community/loki `
  --namespace logging --values helm/loki-values.yaml `
  --wait --timeout 10m

helm upgrade --install alloy grafana/alloy `
  --namespace logging --values helm/alloy-values.yaml `
  --wait --timeout 10m

helm upgrade --install grafana grafana-community/grafana `
  --namespace logging --values helm/grafana-values.yaml `
  --wait --timeout 10m

helm upgrade --install monitoring-grafana ./helm/grafana `
  --namespace logging --wait --timeout 5m

kubectl rollout restart deployment/grafana -n logging
kubectl rollout status deployment/grafana -n logging --timeout=5m

Write-Host "Monitoring stack installed successfully."
