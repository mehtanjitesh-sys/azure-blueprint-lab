param(
  [string]$Path = "."
)

$ErrorActionPreference = "Stop"

$blockedFilePatterns = @(
  "\.tfstate$",
  "\.tfstate\.",
  "\.tfplan$",
  "\.plan$",
  "\\\.terraform\\",
  "\\bin\\",
  "\\obj\\",
  "local\.settings\.json$",
  "terraform\.tfvars$",
  "\.auto\.tfvars$",
  "\.tfvars\.json$",
  "\.pem$",
  "\.pfx$",
  "\.p12$",
  "\.key$",
  "\.kubeconfig$",
  "\.zip$"
)

$sensitiveContentPatterns = @(
  "client_secret\s*=",
  "clientSecret",
  "ARM_CLIENT_SECRET",
  "AccountKey=",
  "access_key\s*=",
  "sas_token\s*=",
  "shared_access_key",
  "DefaultEndpointsProtocol=https;AccountName=.*AccountKey=",
  "-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----",
  "gh[pousr]_[A-Za-z0-9_]{30,}",
  "eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"
)

$allowedGuids = @(
  # Microsoft built-in Azure role definition IDs used by the examples.
  "7f951dda-4ed3-4680-a7ca-43fe172d538d",
  "b7e6dc6d-f1e8-4753-8033-0f276bb0955b",
  "974c5e8b-45b9-4653-ba55-5f855dd0fb88",
  "0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3"
)

$findings = New-Object System.Collections.Generic.List[string]

$files = Get-ChildItem -Path $Path -Recurse -File -Force |
  Where-Object {
    $_.FullName -notmatch "\\\.git\\" -and
    $_.FullName -notmatch "\\\.terraform\\" -and
    $_.FullName -notmatch "\\bin\\" -and
    $_.FullName -notmatch "\\obj\\"
  }

foreach ($file in $files) {
  $relative = Resolve-Path -Path $file.FullName -Relative

  foreach ($pattern in $blockedFilePatterns) {
    if ($file.FullName -match $pattern) {
      $findings.Add("Blocked file pattern: $relative")
    }
  }

  if ($file.Length -gt 2MB) {
    continue
  }

  $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
  if ($null -eq $content) {
    continue
  }

  foreach ($pattern in $sensitiveContentPatterns) {
    if ($relative -notmatch "scripts\\Test-PublicRepoSafety\.ps1$" -and $content -match $pattern) {
      $findings.Add("Sensitive content pattern '$pattern': $relative")
    }
  }

  $guidMatches = [regex]::Matches($content, "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
  foreach ($match in $guidMatches) {
    if ($allowedGuids -notcontains $match.Value.ToLowerInvariant()) {
      $findings.Add("Review GUID value '$($match.Value)' in $relative")
    }
  }
}

if ($findings.Count -gt 0) {
  Write-Host "Public repo safety scan found items to review:" -ForegroundColor Yellow
  $findings | Sort-Object -Unique | ForEach-Object { Write-Host "- $_" }
  exit 1
}

Write-Host "Public repo safety scan passed." -ForegroundColor Green
