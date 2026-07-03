# Validation Evidence

This repo becomes stronger when validation proof is captured in a consistent, sanitized way. Do not commit raw output.

## Evidence Standard

For each blueprint, capture:

- Bicep build result
- Terraform `fmt` result
- Terraform `init -backend=false` result
- Terraform `validate` result
- Optional sanitized Terraform plan summary
- Optional screenshot with subscription IDs, tenant IDs, object IDs, public IPs, and account names redacted
- Short "What I validated" note
- Cleanup command

## Sanitizing Output

Save raw command output outside the repo or under an ignored `evidence/raw` folder, then sanitize it:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Sanitize-Evidence.ps1 `
  -InputPath .\blueprints\01-secure-network-entry\evidence\raw\terraform-validate.txt `
  -OutputPath .\blueprints\01-secure-network-entry\evidence\terraform-validate-sanitized.md
```

Run the public repo safety check before commit:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-PublicRepoSafety.ps1
```

## Evidence Checklist

| Blueprint | Bicep Build | Terraform Validate | Plan/What-If | Screenshot | Notes |
| --- | --- | --- | --- | --- | --- |
| 01 Secure Network Entry | Pending | Pending | Pending | Pending | Pending |
| 02 Autoscaling Web Compute | Pending | Pending | Pending | Pending | Pending |
| 03 Event-Driven Image Pipeline | Pending | Pending | Pending | Pending | Pending |
| 04 Private Container Platform | Pending | Pending | Pending | Pending | Pending |

Replace `Pending` only after running the commands and saving sanitized evidence.
