$ErrorActionPreference = "Stop"

kubectl config use-context docker-desktop

Write-Host "=== Pods ==="
kubectl get pods -n logging

Write-Host "=== Services ==="
kubectl get svc -n logging

Write-Host "=== PVCs ==="
kubectl get pvc -n logging

Write-Host "=== Helm releases ==="
helm list -n logging

Write-Host "Monitoring verification complete."
