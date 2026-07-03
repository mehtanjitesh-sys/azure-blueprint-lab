param(
  [Parameter(Mandatory = $true)]
  [string]$InputPath,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$content = Get-Content -LiteralPath $InputPath -Raw

$redactions = @(
  @{ Pattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"; Replacement = "<guid-redacted>" },
  @{ Pattern = "/subscriptions/[^/\s]+"; Replacement = "/subscriptions/<subscription-id>" },
  @{ Pattern = "tenantId['""]?\s*[:=]\s*['""]?[^,'""\s]+"; Replacement = "tenantId: <tenant-id>" },
  @{ Pattern = "clientId['""]?\s*[:=]\s*['""]?[^,'""\s]+"; Replacement = "clientId: <client-id>" },
  @{ Pattern = "principalId['""]?\s*[:=]\s*['""]?[^,'""\s]+"; Replacement = "principalId: <principal-id>" },
  @{ Pattern = "AccountKey=[^;""'\s]+"; Replacement = "AccountKey=<redacted>" },
  @{ Pattern = "SharedAccessSignature=[^;""'\s]+"; Replacement = "SharedAccessSignature=<redacted>" },
  @{ Pattern = "([0-9]{1,3}\.){3}[0-9]{1,3}"; Replacement = "<ip-redacted>" }
)

foreach ($redaction in $redactions) {
  $content = [regex]::Replace($content, $redaction.Pattern, $redaction.Replacement)
}

$directory = Split-Path -Parent $OutputPath
if ($directory) {
  New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8
Write-Host "Sanitized evidence written to $OutputPath"
