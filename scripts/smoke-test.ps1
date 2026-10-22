[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl was not found in PATH."
}

$manifestPath = Join-Path $PSScriptRoot "smoke-client.yaml"
if (-not (Test-Path $manifestPath)) {
    throw "Smoke-client manifest was not found at $manifestPath."
}

kubectl -n homelab delete -f $manifestPath --ignore-not-found

try {
    Write-Host "Requesting the Service from a hardened ephemeral in-cluster client..."
    kubectl apply -f $manifestPath

    $phase = ""
    for ($attempt = 1; $attempt -le 18; $attempt++) {
        $phase = kubectl -n homelab get pod hello-web-smoke -o jsonpath='{.status.phase}'
        if ($phase -in @("Succeeded", "Failed")) {
            break
        }
        Start-Sleep -Seconds 5
    }

    $response = kubectl -n homelab logs hello-web-smoke
    if ($phase -ne "Succeeded") {
        throw "Smoke client finished in phase '$phase'. Output: $response"
    }
    if (($response | Out-String) -notmatch "Hello from K3s") {
        throw "Smoke test returned an unexpected application response."
    }

    Write-Host "PASS: Service returned the expected application response."
}
finally {
    kubectl -n homelab delete -f $manifestPath --ignore-not-found
}
