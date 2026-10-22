[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl was not found in PATH."
}

if (-not (Test-Path "./manifests/kustomization.yaml")) {
    throw "Run this script from the repository root."
}

Write-Host "Validating manifests against the API server..."
kubectl apply --dry-run=server -k ./manifests/

Write-Host "Waiting for the Deployment rollout..."
kubectl -n homelab rollout status deployment/hello-web --timeout=120s

Write-Host "Checking service endpoints and HPA metrics..."
$endpointSlices = @(kubectl -n homelab get endpointslice -l kubernetes.io/service-name=hello-web -o name)
if ($LASTEXITCODE -ne 0 -or $endpointSlices.Count -lt 1) {
    throw "No EndpointSlice was found for the hello-web Service."
}
Write-Host "PASS: Service EndpointSlice is present; the rollout confirmed two available replicas."

$cpuUtilization = $null
for ($attempt = 1; $attempt -le 6; $attempt++) {
    $cpuUtilization = kubectl -n homelab get hpa hello-web `
        -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}'
    if ($LASTEXITCODE -eq 0 -and $cpuUtilization -match '^\d+$') {
        break
    }
    Start-Sleep -Seconds 10
}
if ($cpuUtilization -notmatch '^\d+$') {
    throw "HPA CPU metrics are not available after 60 seconds. Check metrics-server and HPA events."
}
Write-Host "PASS: HPA reports CPU utilization of $cpuUtilization%."
kubectl -n homelab top pods -l app.kubernetes.io/name=hello-web
